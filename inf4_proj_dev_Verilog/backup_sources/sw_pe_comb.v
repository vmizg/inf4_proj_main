Y_o  = Y_i;
diag = top;
top  = top_i;

// Avoiding underflow
i1 = (left == 16'd0) ? 16'd0 : left - gap;
i2 = (top == 16'd0) ? 16'd0 : top - gap;

if (X_i == Y_i)
    ms = diag + match;
else
    ms = (diag == 16'd0) ? 16'd0 : diag - mismatch;

if (i1 >= i2 && i1 >= ms)
    score_o = i1;
else if (i2 >= i1 && i2 >= ms)
    score_o = i2;
else
    score_o = ms;   

left = score_o;
valid_o = 1'b1;
