#include <string>
#include <vector>

#ifndef INF4_DNA_TESTBENCH_ALIGN_H
#define INF4_DNA_TESTBENCH_ALIGN_H

#endif //INF4_DNA_TESTBENCH_ALIGN_H

typedef struct DNode DNode;
struct DNode {
    char base;
    DNode *next;
};

class StdElement {
    char X_in;
    int bottom = 0, left = 0, diag = 0, top = 0, score = 0;
    int match = 2, mismatch = -1, gap = -1;
public:
    explicit StdElement(char S, int match = 2, int mismatch = -1, int gap = -1);
    int align(char, int);
    int getBottom();
    int getScore();
};

class StdProc {
    DNode *Y_root;
    char *X, *Y;
    long X_len, Y_len;

    std::vector<char> Y_shift_reg;
    std::vector<StdElement> pe_array;
public:
    int *score_matrix;

    StdProc(char *X, int X_len, char *Y, int Y_len);
    void process();
    void print();
};