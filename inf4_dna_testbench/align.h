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
    char S_in;
    int bottom_out = 0, left = 0, diag = 0, top = 0, score = 0;
    int match = 2, mismatch = -1, gap = -1;
public:
    explicit StdElement(char S, int match = 2, int mismatch = -1, int gap = -1);
    int align(char, int);
    int bottom();
};

class StdProc {
    DNode *T_root;
    long S_len, T_len;

    std::vector<char> T_shift_reg;
    std::vector<StdElement> pe_array;
public:
    int score_matrix[300][300] = {};

    StdProc(std::string &S, std::string &T);
    void process();
};