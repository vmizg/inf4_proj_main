#include <iostream>
#include <fstream>
#include <vector>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <cassert>
#include "align.h"

using namespace std;

StdElement::StdElement(char X, int match, int mismatch, int gap) {
    this->X_in = X;
    this->match = match;
    this->mismatch = mismatch;
    this->gap = gap;
}

int StdElement::align(char Y, int top_in) {
    // Diagonal value is the value from upper PE at T-2 time
    this->diag = this->top;

    // Top value is the value from upper PE at T-1 time
    this->top = top_in;

    // Debug
    // printf("X: %c, Y: %c - ", this->X_in, Y);
    // printf("Left=%d, Diag=%d, Top=%d", this->left, this->diag, this->top);

    // F(i-1,j-1) + S(xi,yi) = diagonal value + match / mismatch
    int ms = (this->X_in == Y) ?
                 this->diag + this->match :
                 this->diag + this->mismatch;

    // Left value - gap penalty
    int i1 = this->left + this->gap;

    // Top value - gap penalty
    int i2 = this->top + this->gap;

    // Score
    this->score = max(max(ms, i1), max(i2, 0));

    // Save previous score (current left value) to be used as top input for PE+1, T+1 time
    this->bottom = this->left;

    // Save score to be used as left value for T+1 time
    this->left = this->score;

    // Debug
    // printf(", score=%d \n", this->score);

    // Return score to write to score matrix
    return this->score;
}

int StdElement::getBottom() {
    return this->bottom;
}

int StdElement::getScore() {
    return this->score;
}

StdProc::StdProc(char *X, int X_len, char *Y, int Y_len) {
    this->X      = X;
    this->Y      = Y;
    this->X_len  = X_len;
    this->Y_len  = Y_len;
    this->Y_root = new DNode;

    this->score_matrix = new int[X_len*Y_len];

    for (int i = 0; i < X_len; i++) {
        StdElement pe = StdElement(X[i]);
        this->pe_array.emplace_back(pe);
    }

    this->Y_root->base = Y[0];
    this->Y_root->next = nullptr;

    DNode *curr_node = this->Y_root;

    for (auto i = 1; i < Y_len; i++) {
        auto *temp = new DNode;
        temp->base = Y[i];
        temp->next = nullptr;
        curr_node->next = temp;
        curr_node = temp;
    }

    curr_node->next = this->Y_root;
}

void StdProc::process() {
    int score_buffer[X_len+1];
    int X_window = 1;
    int top_in = 0;

    for (int i = 0; i < X_len+1; i++) {
        score_buffer[i] = 0;
    }
    Y_shift_reg.push_back(Y_root->base);

    // TIME     0     1  0     2  1  0     3  2  1  0
    // PE 0     []    [] []    [] [] []    [] [] [] []
    // PE 1        => []    => [] []    => [] [] []
    // PE 2                    []          [] []
    // PE 3                                []

    // Starting to operate first PEs
    // 1 PE, 2 PEs in parallel, 3 PEs in parallel ... < X_len PEs in parallel
    while (X_window < this->X_len) {
        // Debug
        // printf("Initial run No. %d \n", X_window);

        for (int j = 0; j < X_window; j++) {
            top_in = j == 0 ? 0 : pe_array[j-1].getBottom();
            score_buffer[j] = pe_array[j].align(Y_shift_reg[X_window-j-1], top_in);
            score_matrix[(j*Y_len)+(X_window-j-1)] = score_buffer[j];
        }

        Y_root = Y_root->next;
        Y_shift_reg.push_back(Y_root->base);
        X_window = int(Y_shift_reg.size());
    }

    // At this stage, all PEs are running
    // length(PE_array) == X_len
    int start_col = 0;
    while (start_col < Y_len - X_window) {
        // Debug
        // printf("Full run No. %d \n", start_col);

        for (int j = 0; j < X_window; j++) {
            top_in = j == 0 ? 0 : pe_array[j-1].getBottom();
            score_buffer[j] = pe_array[j].align(Y_shift_reg[X_window-j-1], top_in);
            score_matrix[(j*Y_len)+(X_window+start_col-j-1)] = score_buffer[j];
        }
        start_col++;

        Y_root = Y_root->next;
        Y_shift_reg.push_back(Y_root->base);
        Y_shift_reg.erase(Y_shift_reg.begin());
    }

    // At this stage, remaining scores are calculated
    // X_len PEs operate, X_len-1 PEs operate, ... 1 PE operates, halt.
    int start_row = 0;
    while (start_col < Y_len) {
        // Debug
        // printf("Finishing run No. %d \n", start_row);

        for (int j = start_row; j < X_window; j++) {
            top_in = j == 0 ? 0 : pe_array[j-1].getBottom();
            score_buffer[j] = pe_array[j].align(Y_shift_reg[X_window-j-1], top_in);
            score_matrix[(j*Y_len)+(X_window+start_col-j-1)] = score_buffer[j];
        }
        start_col++;
        start_row++;

        Y_root = Y_root->next;
        Y_shift_reg.erase(Y_shift_reg.begin());
    }
}

void StdProc::print() {
    printf("\n  | ");
    for (int k = 0; k < Y_len; ++k) {
        printf("%c | ", Y[k]);
    }
    printf("\n");

    for (int i = 0; i < X_len; i++) {
        printf("%c | ", X[i]);
        for (int j = 0; j < Y_len; j++) {
            printf("%d | ", score_matrix[(i*Y_len)+j]);
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
    auto BASELEN = (int) st.st_size;
    stat(streamseq, &st);
    auto STREAMLEN = (int) st.st_size;

    if (STREAMLEN > 1200000) {
        printf("Stream sequence too long to process, max 1,200,000 bases");
        exit(1);
    }

    printf("X length: %d, Y length: %d \n", BASELEN, STREAMLEN);

    int fd_x = open(baseseq, O_RDONLY, 0);
    int fd_y = open(streamseq, O_RDONLY, 0);
    assert (fd_x != -1 && fd_y != -1);

    auto *seq_X = (char *) mmap(nullptr, BASELEN * sizeof(char), PROT_READ, MAP_PRIVATE | MAP_POPULATE, fd_x, 0);
    auto *seq_Y = (char *) mmap(nullptr, STREAMLEN * sizeof(char), PROT_READ, MAP_PRIVATE | MAP_POPULATE, fd_y, 0);
    assert(seq_X != MAP_FAILED && seq_Y != MAP_FAILED);

    StdProc p = StdProc(seq_X, BASELEN, seq_Y, STREAMLEN);
    p.process();
    p.print();

    int fin_x = munmap(seq_X, BASELEN * sizeof(char));
    int fin_y = munmap(seq_Y, STREAMLEN * sizeof(char));
    assert (fin_x == 0 && fin_y == 0);

    close(fd_x);
    close(fd_y);

    return 0;
}