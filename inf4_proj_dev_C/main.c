#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <fcntl.h>
#include <asm/errno.h>
#include <errno.h>
#include <sys/stat.h>

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

        // int i;
        // for (i = 0; i < 160; i++)
        //     printf("%d | ", (int) buf[i]);
        // printf("\n\n");

        // Debug
        // printf("Stream total: %d, end total: %d \n", stream_total, end_total);

        while (row < base_total + 1) {
            // printf("Index: [%d][%d] = %d \n", row, col, (int) buf[row]);
            matrix[row*stream_len+col] = (short) buf[row];
            row++;
            col--;
        }
        // printf("\n");

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
    // Measure time
    clock_t time_start = clock();

    short *matrix = (short *) malloc(sizeof(short) * BASELEN * STREAMLEN);
    printf("Allocated %d space for score matrix \n", (int) sizeof(short) * BASELEN * STREAMLEN);

    int read_handle;
    int sseq_out;
    int bseq_out;

    /* OPEN INTERFACES *****************************************/
    // Open score read interface
    read_handle = open("/dev/xillybus_stream_score_out", O_RDONLY);
    if (read_handle < 0) {
        perror("Failed to open xillybus_score_stream_out interface");
        exit(1);
    }

    // Open base sequence write interface
    bseq_out = open("/dev/xillybus_stream_dna_x", O_WRONLY);
    if (bseq_out < 0) {
        perror("Failed to open xillybus_stream_dna_x interface");
        return;
    }

    // Open stream sequence write interface
    sseq_out = open("/dev/xillybus_stream_dna_y", O_WRONLY);
    if (sseq_out < 0) {
        perror("Failed to open xillybus_stream_dna_y interface");
        return;
    }

    // Start a read thread here
    pthread_t read_thread;
    threadargs args;
    args.base_len = BASELEN;
    args.stream_len = STREAMLEN;
    args.matrix = matrix;
    args.read_handle = read_handle;

    pthread_create(&read_thread, PTHREAD_CREATE_JOINABLE, process_scores, &args);
    printf("Created thread for reading scores... \n");

    /* WRITE SEQUENCE X ****************************************/
    int i;
    int j;
    ssize_t bw;

    int blen_mod = BASELEN % 16;
    int blen = BASELEN - blen_mod;

    for (i = 15; i < blen; i = i + 16) {
        unsigned long partseq = 0;
        // printf("[X] ");
        for (j = i; j >= i - 15; j--) {
            switch (baseseq[j]) {
                case 97:
                case 65: { // A
                    // printf("A");
                    partseq = (partseq << 2);
                    break;
                }
                case 99:
                case 67: { // C
                    // printf("C");
                    partseq = (partseq << 2) | 1;
                    break;
                }
                case 103:
                case 71: { // G
                    // printf("G");
                    partseq = (partseq << 2) | 2;
                    break;
                }
                case 116:
                case 84: { // T
                    // printf("T");
                    partseq = (partseq << 2) | 3;
                    break;
                }
                default: ;
            }
        }

        // printf(", in 32-bit: %ld \n", partseq);
        // printBits(4, &partseq);

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
        unsigned long partseq = 0;
        // printf("[X] ");
        for (j = blen + blen_mod - 1; j >= blen; j--) {
            switch (baseseq[j]) {
                case 97:
                case 65: { // A
                    // printf("A");
                    partseq = (partseq << 2);
                    break;
                }
                case 99:
                case 67: { // C
                    // printf("C");
                    partseq = (partseq << 2) | 1;
                    break;
                }
                case 103:
                case 71: { // G
                    // printf("G");
                    partseq = (partseq << 2) | 2;
                    break;
                }
                case 116:
                case 84: { // T
                    // printf("T");
                    partseq = (partseq << 2) | 3;
                    break;
                }
                default: ;
            }
        }

        // printf(", in 32-bit: %ld \n", partseq);
        // printBits(4, &partseq);

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

    /* WRITE SEQUENCE Y ****************************************/
    ssize_t sw;

    int slen_mod = STREAMLEN % 16;
    int slen = STREAMLEN - slen_mod;

    for (i = 15; i < slen; i = i + 16) {
        unsigned long partseq = 0;
        // printf("[Y] ");
        for (j = i; j >= i - 15; j--) {
            switch (streamseq[j]) {
                case 97:
                case 65: { // A
                    // printf("A");
                    partseq = (partseq << 2);
                    break;
                }
                case 99:
                case 67: { // C
                    // printf("C");
                    partseq = (partseq << 2) | 1;
                    break;
                }
                case 103:
                case 71: { // G
                    // printf("G");
                    partseq = (partseq << 2) | 2;
                    break;
                }
                case 116:
                case 84: { // T
                    // printf("T");
                    partseq = (partseq << 2) | 3;
                    break;
                }
                default: ;
            }
        }

        // printf(", in 32-bit: %ld \n", partseq);
        // printBits(4, &partseq);

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
        unsigned long partseq = 0;
        // printf("[Y] ");
        for (j = slen + slen_mod - 1; j >= slen; j--) {
            switch (streamseq[j]) {
                case 97:
                case 65: { // A
                    // printf("A");
                    partseq = (partseq << 2);
                    break;
                }
                case 99:
                case 67: { // C
                    // printf("C");
                    partseq = (partseq << 2) | 1;
                    break;
                }
                case 103:
                case 71: { // G
                    // printf("G");
                    partseq = (partseq << 2) | 2;
                    break;
                }
                case 116:
                case 84: { // T
                    // printf("T");
                    partseq = (partseq << 2) | 3;
                    break;
                }
                default: ;
            }
        }

        // printf(", in 32-bit: %ld \n", partseq);
        // printBits(4, &partseq);

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
    printf("Successfully written sequence Y into device! \n \n");

    pthread_join(read_thread, NULL);
    close(read_handle);

    clock_t time_end = clock();
    double time_spent = (double) (time_end - time_start) / CLOCKS_PER_SEC;

    printf("Matrix building finished. Time elapsed: %lf s \n", time_spent);

    // Debug
//    printf("Score matrix: \n");
//
//    int k;
//    printf("\n  | ");
//    for (k = 0; k < STREAMLEN; ++k) {
//        printf("%c | ", streamseq[k]);
//    }
//    printf("\n");
//
//    for (i = 0; i < BASELEN; i++) {
//        printf("%c | ", baseseq[i]);
//        for (j = 0; j < STREAMLEN; j++) {
//            printf("%d | ", matrix[(i*STREAMLEN)+j]);
//        }
//        printf("\n");
//    }
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

    FILE * fd_x;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    fd_x = fopen(baseseq, "r");
    if (fd_x == NULL)
        exit(EXIT_FAILURE);

    int i;
    int total = 0;
    char *seq_X = (char *) malloc(sizeof(char) * BASELEN);

    while ((read = getline(&line, &len, fd_x)) != -1) {
        for (i = 0; i < read; i++) {
            if (line[i] == '\n')
                break;
            seq_X[total+i] = line[i];
        }
        total = total + (int) read;
    }
    fclose(fd_x);

    FILE * fd_y;
    line = NULL;
    len = 0;

    fd_y = fopen(streamseq, "r");
    if (fd_y == NULL)
        exit(EXIT_FAILURE);

    total = 0;
    char *seq_Y = (char *) malloc(sizeof(char) * STREAMLEN);
    while ((read = getline(&line, &len, fd_y)) != -1) {
        for (i = 0; i < read; i++) {
            if (line[i] == '\n')
                break;
            seq_Y[total+i] = line[i];
        }
        total = total + (int) read;
    }
    fclose(fd_y);

    process(BASELEN, STREAMLEN, seq_X, seq_Y);

    return 0;
}