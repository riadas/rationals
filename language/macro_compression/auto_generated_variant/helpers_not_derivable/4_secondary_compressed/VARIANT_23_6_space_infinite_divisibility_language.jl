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

@relate RN Divide
@macro_expand f arg1 arg2 = @relate (arg1, CQ) (arg2, RN)
@f halve_obj halve
@f double_obj double
@f split_obj divide_n
@f combine_obj multiply_m
@f divide_obj divide_n_m

# subroutines / helpers
function common_multiple(arg1::NN, arg2::NN)
   NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

function scale(rn::RN, nn::NN)
   RN(rn.numerator * nn, rn.denominator * nn, false)
end

@generalize (NN_op, NN) (RN_op, RN)

function RN_add(x::RN, y::RN)
    RN(arg1.numerator + arg2.numerator, arg1.denominator + arg2.denominator)
end

infinite_divisibility_space = infinite