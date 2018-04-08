#include <iostream>
#include <fstream>
#include <vector>
#include "align.h"

using namespace std;

StdElement::StdElement(char S, int match, int mismatch, int gap) {
    this->S_in = S;
    this->match = match;
    this->mismatch = mismatch;
    this->gap = gap;
}

int StdElement::align(char T, int top_in) {
    // Diagonal value is the value from upper PE at T-2 time
    this->diag = this->top;

    // Top value is the value from upper PE at T-1 time
    this->top = top_in;

    cout << "S: " << this->S_in << ", T: " << T << " - "; // DEBUG
    cout << "Left=" << this->left << ", Diag=" << this->diag << ", Top=" << this->top; // DEBUG

    // F(i-1,j-1) + S(xi,yi) = diagonal value + match / mismatch
    int ms = (this->S_in == T) ?
                 this->diag + this->match :
                 this->diag + this->mismatch;

    // Left value - gap penalty
    int i1 = this->left + this->gap;

    // Top value - gap penalty
    int i2 = this->top + this->gap;

    // Score
    this->score = max(max(ms, i1), max(i2, 0));

    // Save previous score (current left value) to be used as top input for PE+1, T+1 time
    this->bottom_out = this->left;

    // Save score to be used as left value for T+1 time
    this->left = this->score;

    cout << ", score=" << this->score << endl; // DEBUG

    // Return score to write to score matrix
    return this->score;
}

int StdElement::bottom() {
    return this->bottom_out;
}

StdProc::StdProc(string &S, string &T) {
    this->S_len = S.length();
    this->T_len = T.length();
    this->T_root = new DNode;

    for (int i = 0; i < S_len; i++) {
        StdElement pe = StdElement(S[i]);
        this->pe_array.emplace_back(pe);
    }

    this->T_root->base = T[0];
    this->T_root->next = nullptr;

    DNode *curr_node = this->T_root;

    for (auto i = 1; i < T_len-1; i++) {
        auto *temp = new DNode;
        temp->base = T[i];
        temp->next = nullptr;
        curr_node->next = temp;
        curr_node = temp;
    }

    curr_node->next = this->T_root;
}

void StdProc::process() {
    //int T_pos = 0;
    int score_buffer[S_len+1];
    T_shift_reg.push_back(T_root->base);
    int shift_reg_size = 1;

    for (int i = 0; i < S_len+1; i++) {
        score_buffer[i] = 0;
    }

    // TIME     0     1  0     2  1  0     3  2  1  0
    // PE 0     []    [] []    [] [] []    [] [] [] []
    // PE 1        => []    => [] []    => [] [] []
    // PE 2                    []          [] []
    // PE 3                                []

    // Starting to operate first PEs
    // 1 PE, 2 PEs in parallel, 3 PEs in parallel ... < S_len PEs in parallel
    while (shift_reg_size < this->S_len) {
        cout << endl << "Initial run No. " << shift_reg_size << endl;
        for (int j = 0; j < shift_reg_size; j++) {
            int top_in = j == 0 ? 0 : pe_array[j-1].bottom();

            score_buffer[j] = pe_array[j].align(T_shift_reg[shift_reg_size-j-1], top_in);
            score_matrix[j][shift_reg_size-j-1] = score_buffer[j];
        }

        T_root = T_root->next;
        T_shift_reg.push_back(T_root->base);
        shift_reg_size = int(T_shift_reg.size());
    }

    // At this stage, all PEs are running
    // length(PE_array) == S_len
    for (int i = 0; i < T_len; i++) {
        cout << endl << "Full run No. " << i << endl;
        for (int j = 0; j < shift_reg_size; j++) {
            int top_in = j == 0 ? 0 : pe_array[j-1].bottom();

            score_buffer[j] = pe_array[j].align(T_shift_reg[shift_reg_size-j-1], top_in);
            score_matrix[j][shift_reg_size+i-j-1] = score_buffer[j];
        }

        T_root = T_root->next;
        T_shift_reg.push_back(T_root->base);
        T_shift_reg.erase(T_shift_reg.begin());
    }
}

int main() {
    ifstream in;
    in.open("dna_test.txt");
    string S, T;
    getline(in, T);
    getline(in, S);
    in.close();

    StdProc p = StdProc(S, T);
    p.process();

    cout << endl << endl << "  | ";
    for (int k = 0; k < 16; ++k) {
        cout << T[k] << " | ";
    }
    cout << endl;

    for (int i = 0; i < 16; i++) {
        cout << S[i] << " | ";
        for (int j = 0; j < 16; j++) {
            cout << p.score_matrix[i][j] << " | ";
        }
        cout << endl;
    }

    return 0;
}