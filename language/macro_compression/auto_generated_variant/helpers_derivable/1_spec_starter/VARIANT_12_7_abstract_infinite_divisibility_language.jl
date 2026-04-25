function halve(x::RN=RN(1, 1))::RN 
    divide_n(x, 2)
end

function double(x::RN=RN(1, 1))::RN 
    multiply_m(x, m)
end

RN(x::NN) = RN(x, NN(1))

 
function divide_n(x::RN=RN(1, 1), n::NN)::RN
   RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)::RN
   RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)::RN
   multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end

@relate CQ RN
@generalize NN RN
@relate RN Divide
@relate (halve_obj, CQ) (halve, RN)
@relate (double_obj, CQ) (double, RN)
@relate (split_obj, CQ) (divide_n, RN)
@relate (combine_obj, CQ) (multiply_m, RN)
@relate (divide_obj, CQ) (divide_n_m, RN)
@generalize (NN_op, NN) (RN_op, RN)


function RN_add(x::RN, y::RN)
    RN(arg1.numerator + arg2.numerator, arg1.denominator + arg2.denominator)
end
function RN_subtract(x::RN, y::RN)
    RN(arg1.numerator - arg2.numerator, arg1.denominator - arg2.denominator)
end
function RN_compare(x::RN, y::RN)
    NullNumber
end

infinite_divisibility_space = infinite
infinite_divisibility_number = infinite
infinite_divisibility_weight = infinite