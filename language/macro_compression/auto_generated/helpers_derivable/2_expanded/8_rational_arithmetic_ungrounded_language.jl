abstract type NumberSymbol end
abstract type PhysicalQuantity end
abstract type NaturalNumber <: NumberSymbol end
abstract type RationalNumber <: NaturalNumber end
abstract type DiscreteQuantity <: PhysicalQuantity end

struct NN <: NaturalNumber
    value::Int
end

struct DQ <: DiscreteQuantity
    size::NN
end

struct RN <: RationalNumber
    num::NN
    denom::NN
end

function halve_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Subtract(n, n - 1)))
end

function double_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Add(1, m - 1)))
end

RN(x::NN) = RN(x, NN(1))
NN(x::RN) = x.num == NN(1) ? x.num : NullNumber

function halve(x::RN=RN(1, 1))::RN
    divide_n(x, 2)
end

function double(x::RN=RN(1, 1))::RN
    multiply_m(x, m)
end

RN(x::Divide) = RN(x.arg1, x.arg2)
Divide(x::RN) = Divide(x.num, x.denom)

RN(x::Subtract) = x.arg1 < x.arg2 ? RN(x.arg1, x.arg2) : NullNumber
Subtract(x::RN) = x.num < x.denom ? Subtract(x.num, x.denom) : NullNumber

function divide_n(x::RN=RN(1, 1), n::NN)::RN
   RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)::RN
   RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)::RN
   multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end

function split_obj(x::PQ=PQ(Hidden(RN(1, 1))), n::NN)::PQ
   build(DQ(x, Subtract(n, n - 1)))
end

function combine_obj(x::PQ=PQ(Hidden(RN(1, 1))), m::NN)::PQ
   build(DQ(x, Add(1, m - 1)))
end

function divide_obj(x::PQ=PQ(Hidden(RN(1, 1))), n::NN)::PQ
   combine_obj(split_obj(x, n), m)
end

function RN_op(x::RN, y::RN, op::Symbol)
   cm = common_multiple(arg1.denominator, arg2.denominator)
   scaled_arg1 = scale(arg1, cm / arg1.denominator)
   scaled_arg2 = scale(arg2, cm / arg2.denominator)
   RN(eval(op)(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

# subroutines / helpers
function common_multiple(arg1::NN, arg2::NN)
   NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

function scale(rn::RN, nn::NN)
   RN(rn.numerator * nn, rn.denominator * nn, false)
end