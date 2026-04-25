NN(x::RN) = x.denom == NN(1) ? x.num : error("invalid cast")
RN(x::NN) = RN(x, NN(1))

@relate CQ RN
@generalize NN RN
@relate RN Divide

function halve(x::RN=RN(1, 1))::RN 
    divide_n(x, 2)
end

function double(x::RN=RN(1, 1))::RN 
    multiply_m(x, m)
end

function divide_n(x::RN=RN(1, 1), n::NN)::RN
   RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)::RN
   RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)::RN
   multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end

@relate (halve_obj, CQ) (halve, RN)
@relate (double_obj, CQ) (double, RN)
@relate (split_obj, CQ) (divide_n, RN)
@relate (combine_obj, CQ) (multiply_m, RN)
@relate (divide_obj, CQ) (divide_n_m, RN)

@generalize (NN_op, NN) (RN_op, RN)

# subroutines / helpers
function common_multiple(arg1::NN, arg2::NN)
   NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

@invariant eq
function scale(rn::RN, nn::NN)
   RN(rn.numerator * nn, rn.denominator * nn, false)
end