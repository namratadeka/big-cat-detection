function y = isgreater(A,B)
    if A(1,1)>=B(1,1) && A(1,2)>=B(1,2) && A(1,3)>=B(1,3)
        y = 1;
    else
        y = 0;
    end
end