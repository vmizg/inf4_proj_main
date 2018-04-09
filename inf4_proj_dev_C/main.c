#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <fcntl.h>
#include <asm/errno.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <assert.h>

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

    unsigned long buf[160];
    int base_total = 0;
    int stream_total = 0;
    int row = 0;
    int col = 0;
    int end_total = 0;
    ssize_t br;

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
        printf("Stream total: %d, end total: %d \n", stream_total, end_total);

        while (row < base_total + 1) {
            printf("At index: [%d][%d] = %d \n", row, col, (int) buf[row]);
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

void process(int BASELEN, int STREAMLEN, char *baseseq, char *streamseq) {
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
    printf("Opened xillybus score read interface \n");

    // Open base sequence write interface
    int bseq_out;
    bseq_out = open("/dev/xillybus_stream_dna_x", O_WRONLY);
    if (bseq_out < 0) {
        perror("Failed to open xillybus_stream_dna_x interface");
        return;
    }
    printf("Opened xillybus X write interface \n");

    // Open stream sequence write interface
    int sseq_out;
    sseq_out = open("/dev/xillybus_stream_dna_y", O_WRONLY);
    if (sseq_out < 0) {
        perror("Failed to open xillybus_stream_dna_y interface");
        return;
    }
    printf("Opened xillybus Y write interface \n");

    /* WRITE SEQUENCE X ****************************************/
    int i;
    int j;
    ssize_t bw;
    unsigned long partseq;

    int blen_mod = BASELEN % 16;
    int blen = BASELEN - blen_mod;

    for (i = blen - 1; i >= 0; i = i - 16) {
        partseq = 0 << 1;
        printf("[X] ");
        for (j = i; j >= i - 15; j--) {
            partseq = extend_bin_sequence(partseq, baseseq[j]);
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

    if (blen_mod > 0) {
        partseq = 0 << 1;
        printf("[X] ");
        for (i = blen_mod - 1; i >= 0; i--) {
            partseq = extend_bin_sequence(partseq, baseseq[i]);
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
    printf("Successfully written sequence X into device! \n");

    // Start a read thread here
    pthread_t read_thread;
    threadargs args;
    args.base_len = BASELEN;
    args.stream_len = STREAMLEN;
    args.matrix = matrix;
    args.read_handle = read_handle;

    pthread_create(&read_thread, PTHREAD_CREATE_JOINABLE, process_scores, &args);
    printf("Created thread for reading scores... \n");

    /* WRITE SEQUENCE Y ****************************************/
    ssize_t sw;

    int slen_mod = STREAMLEN % 16;
    int slen = STREAMLEN - slen_mod;

    for (i = slen - 1; i >= 0; i = i - 16) {
        partseq = 0 << 1;
        printf("[Y] ");
        for (j = i; j >= i - 15; j--) {
            partseq = extend_bin_sequence(partseq, streamseq[j]);
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

    if (slen_mod > 0) {
        partseq = 0 << 1;
        printf("[Y] ");
        for (j = slen_mod - 1; j >= 0; j--) {
            partseq = extend_bin_sequence(partseq, streamseq[j]);
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
    close(sseq_out);
    printf("Successfully written sequence Y into device! Waiting for read... \n \n");

    pthread_join(read_thread, NULL);
    close(read_handle);

    // Debug
    printf("Read thread finished. Results: \n");

    int k;
    printf("\n  | ");
    for (k = 0; k < STREAMLEN; ++k) {
        printf("%c | ", streamseq[k]);
    }
    printf("\n");

    for (i = 0; i < BASELEN; i++) {
        printf("%c | ", baseseq[i]);
        for (j = 0; j < STREAMLEN; j++) {
            printf("%d | ", matrix[(i*STREAMLEN)+j]);
        }
        printf("\n");
    }
}

int main(int argc, char *argv[]) {
    char *baseseq;
    char *streamseq;

    if (argc == 3) {
        baseseq = argv[1];
        streamseq = argv[2];
    } else {
        printf("Wrong arguments, aborting");
        exit(1);
    }

    struct stat st;
    stat(baseseq, &st);
    int BASELEN = (int) st.st_size - 1;
    stat(streamseq, &st);
    int STREAMLEN = (int) st.st_size - 1;

    if (STREAMLEN > 1200000) {
        printf("Stream sequence too long to process, max 1,200,000 bases");
        exit(1);
    }

    printf("X length: %d, Y length: %d \n", BASELEN, STREAMLEN);

    int fd_x = open(baseseq, O_RDONLY, 0);
    int fd_y = open(streamseq, O_RDONLY, 0);
    assert (fd_x != -1 && fd_y != -1);

    char *seq_X = (char *) mmap(NULL, BASELEN * sizeof(char), PROT_READ, MAP_PRIVATE | MAP_POPULATE, fd_x, 0);
    char *seq_Y = (char *) mmap(NULL, STREAMLEN * sizeof(char), PROT_READ, MAP_PRIVATE | MAP_POPULATE, fd_y, 0);
    assert (seq_X != MAP_FAILED && seq_Y != MAP_FAILED);

    process(BASELEN, STREAMLEN, seq_X, seq_Y);

    int fin_x = munmap(seq_X, BASELEN * sizeof(char));
    int fin_y = munmap(seq_Y, STREAMLEN * sizeof(char));
    assert (fin_x == 0 && fin_y == 0);

    close(fd_x);
    close(fd_y);

    return 0;
}