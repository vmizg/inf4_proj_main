#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <fcntl.h>
#include <asm/errno.h>
#include <errno.h>

const int STREAM_BUFFER_LENGTH = 1 * 1024 * 1024;

/* Snippet of code borrowed from https://stackoverflow.com/a/3974138 */
void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;

    for (i = size - 1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    puts("");
}

typedef struct threadargs {
    long base_len;
    long stream_len;
    short *matrix;
    int read_handle;
} threadargs;

unsigned long extend_bin_sequence(unsigned long sequence, char new_base) {
    switch (new_base) {
        case 97:
        case 65: { // A
            printf("A");
            return sequence << 2;
        }
        case 99:
        case 67: { // C
            printf("C");
            return sequence << 2 | 1;
        }
        case 103:
        case 71: { // G
            printf("G");
            return sequence << 2 | 2;
        }
        case 116:
        case 84: { // T
            printf("T");
            return sequence << 2 | 3;
        }
        default: ;
    }
}

void * process_scores(void *arg) {
    long base_len = ((threadargs *) arg)->base_len;
    long stream_len = ((threadargs *) arg)->stream_len;
    short *matrix = ((threadargs *) arg)->matrix;
    int read_handle = ((threadargs *) arg)->read_handle;

    ssize_t br;
    unsigned long buf[160];

    int base_total = 0;
    int stream_total = 0;
    int row = 0;
    int col = 0;
    int end_total = 0;

    while (stream_total != stream_len - 1 || end_total != base_len) {
        br = read(read_handle, &buf, 640);

        if ((br < 0) && (errno == EINTR))
            continue;

        if (br < 0) {
            perror("read() failed");
            break;
        }
        if (br == 0) {
            fprintf(stderr, "Reached read EOF.\n");
            break;
        }

        // Debug
        // printf("Stream total: %d, end total: %d, returned %d... \n", stream_total, end_total, (int) br);

        while (row < base_total + 1) {
            matrix[row*stream_len+col] = (short) buf[row];
            row++;
            col--;
        }

        if (base_total < base_len - 1)
            base_total++;

        if (stream_total < stream_len - 1) {
            stream_total++;
            row = 0;
        } else {
            end_total++;
            row = end_total;
        }

        col = stream_total;
    }
}

void process(int BASELEN, int STREAMLEN, const char *baseseq, const char *streamseq) {
    unsigned char basebuf[BASELEN];
    unsigned char streambuf[STREAM_BUFFER_LENGTH];
    short *matrix = (short *) malloc(sizeof(short) * BASELEN * STREAMLEN);

    // Debug
    printf("Allocated %d space for score matrix \n", (int) sizeof(short) * BASELEN * STREAMLEN);

    /* OPEN INTERFACES *****************************************/
    // Open score read interface
    int read_handle;
    read_handle = open("/dev/xillybus_stream_score_out", O_RDONLY);

    if (read_handle < 0) {
        perror("Failed to open xillybus_score_stream_out interface");
        exit(1);
    }

    // Debug
    printf("Opened xillybus score read interface \n");

    // Open base sequence write interface
    int bseq_out;
    bseq_out = open("/dev/xillybus_stream_dna_x", O_WRONLY);
    if (bseq_out < 0) {
        perror("Failed to open xillybus_stream_dna_x interface");
        return;
    }

    // Debug
    printf("Opened xillybus X write interface \n");

    // Open stream sequence write interface
    int sseq_out;
    sseq_out = open("/dev/xillybus_stream_dna_y", O_WRONLY);
    if (sseq_out < 0) {
        perror("Failed to open xillybus_stream_dna_y interface");
        return;
    }

    // Debug
    printf("Opened xillybus Y write interface \n");

    /* WRITE SEQUENCE X ****************************************/
    // File input for base sequence (reversed!)
    FILE *bseq_in;
    bseq_in = fopen(baseseq, "rb");
    if (bseq_in != NULL) {
        fread(basebuf, (size_t) BASELEN, 1, bseq_in);
        fclose(bseq_in);
    } else {
        perror("Failed to open sequence X file");
        return;
    }

    // Debug
    printf("Successfully read sequence X into buffer! \n");

    int i;
    int j;
    ssize_t bw;
    unsigned long partseq;
    for (i = BASELEN - 1; i >= 0; i = i - 16) {
        partseq = 0 << 1;
        printf("[X] ");
        for (j = i - 16; j < i; j++) {
            partseq = extend_bin_sequence(partseq, basebuf[j+1]);
        }

        printf(", in 32-bit: %ld, in binary: ", partseq);
        printBits(4, &partseq);

        // Write base sequence to FPGA
        while (1) {
            bw = write(bseq_out, &partseq, 4);

            if ((bw < 0) && (errno == EINTR))
                continue;

            if (bw < 0) {
                perror("write() failed");
                return;
            }
            break;
        }
    }
    close(bseq_out);

    // Debug
    printf("Successfully written sequence X into device! \n");

    // Start a read thread here
    pthread_t read_thread;
    threadargs args;
    args.base_len = BASELEN;
    args.stream_len = STREAMLEN;
    args.matrix = matrix;
    args.read_handle = read_handle;

    pthread_create(&read_thread, PTHREAD_CREATE_JOINABLE, process_scores, &args);

    // Debug
    printf("Created thread for reading scores... \n");

    /* WRITE SEQUENCE Y ****************************************/
    // File input for stream sequence (reversed!)
    FILE *sseq_in;
    sseq_in = fopen(streamseq, "rb");
    if (sseq_in == NULL) {
        perror("Failed to open sequence Y file");
        return;
    }

    // Debug
    printf("Opened host Y read interface \n");

    ssize_t fr, sw;

    // Integer to indicate if additional parts of sequence need to be processed
    int extra = STREAMLEN % STREAM_BUFFER_LENGTH;

    while (1) {
        fr = fread(streambuf, STREAM_BUFFER_LENGTH, 1, sseq_in);

        if (fr == 0) {
            // All full parts processed, only additional left
            // or sequence length is less than the buffer length
            break;
        } else {
            for (i = (int) fr - 1; i >= 0; i = i - 16) {
                partseq = 0 << 1;
                printf("[Y] ");
                for (j = i - 16; j < i; j++) {
                    partseq = extend_bin_sequence(partseq, streambuf[j + 1]);
                }

                printf(", in 32-bit: %ld, in binary: ", partseq);
                printBits(4, &partseq);

                // Write stream sequence to FPGA
                while (1) {
                    sw = write(sseq_out, &partseq, 4);

                    if ((sw < 0) && (errno == EINTR))
                        continue;

                    if (sw < 0) {
                        perror("write() failed");
                        return;
                    }
                    break;
                }
            }
        }
    }

    if (extra > 0) {
        // Additional parts have already been read into the buffer
        int new_total = extra;

        if (STREAMLEN % 16 != 0) {
            // Extend the buffer values to fit 16 char word to send to FPGA...
            int fill = 16 - (STREAMLEN % 16);
            new_total = new_total + fill;
            for (i = STREAMLEN; i < STREAMLEN + fill; i++) {
                streambuf[i] = 'A';
            };
        }

        for (i = new_total - 1; i >= 0; i = i - 16) {
            partseq = 0 << 1;
            printf("[Y] ");
            for (j = i - 16; j < i; j++) {
                partseq = extend_bin_sequence(partseq, streambuf[j + 1]);
            }

            printf(", in 32-bit: %ld, in binary: ", partseq);
            printBits(4, &partseq);

            // Write stream sequence to FPGA
            while (1) {
                sw = write(sseq_out, &partseq, 4);

                if ((sw < 0) && (errno == EINTR))
                    continue;

                if (sw < 0) {
                    perror("write() failed");
                    return;
                }
                break;
            }
        }
    }

    fclose(sseq_in);
    close(sseq_out);

    // Debug
    printf("Successfully written sequence Y into device! Waiting for read... \n");

    pthread_join(read_thread, NULL);
    close(read_handle);

    // Debug
    printf("Read thread finished. Results: \n \n");

    int r, c;
    for (r = 0; r < BASELEN; r++) {
        for(c = 0; c < STREAMLEN; c++) {
            printf("%d | ", matrix[r*STREAMLEN+c]);
        }
        printf("\n");
    }
}

int main(int argc, char *argv[]) {
    int BASELEN;
    int STREAMLEN;

    char *baseseq;
    char *streamseq;

    if (argc == 5) {
        BASELEN = (int) strtol(argv[1], NULL, 10);
        baseseq = argv[2];
        STREAMLEN = (int) strtol(argv[3], NULL, 10);
        streamseq = argv[4];

        if (STREAMLEN > 1200000) {
            printf("Stream sequence too long to process, max 1,200,000 bases");
            exit(1);
        }
    } else {
        printf("Wrong arguments, aborting");
        exit(1);
    }

    // Debug
    printf("Arguments passed: %d, %d \n", BASELEN, STREAMLEN);

    process(BASELEN, STREAMLEN, baseseq, streamseq);

    return 0;
}