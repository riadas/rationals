abstract type NumberSymbol end
abstract type PhysicalQuantity end
abstract type RationalNumber <: NumberSymbol end
abstract type NaturalNumber <: RationalNumber end
abstract type ContinuousQuantity <: PhysicalQuantity end
abstract type DiscreteQuantity <: ContinuousQuantity end

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

struct CQ <: ContinuousQuantity
    size::RN
end


function halve(x::RN=RN(1, 1))::RN
    divide_n(x, 2)
end

function double(x::RN=RN(1, 1))::RN
    multiply_m(x, m)
end

RN(x::NN) = RN(x, NN(1))
NN(x::RN) = x.num == NN(1) ? x.num : error("invalid cast")

function divide_n(x::RN=RN(1, 1), n::NN)::RN
   RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)::RN
   RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)::RN
   multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end

RN(x::Divide) = RN(x.arg1, x.arg2)
Divide(x::RN) = Divide(x.num, x.denom)

function halve_obj(x::CQ=CQ(1, 1), function halve(x::RN=RN(1, 1))::RN
    CQ(halve(x.size))
end

function double_obj(x::CQ=CQ(1, 1), function double(x::RN=RN(1, 1))::RN
    CQ(double(x.size))
end

function split_obj(x::CQ=CQ(1, 1), n::NN)::RN
    CQ(divide_n(x.size))
end

function combine_obj(x::CQ=CQ(1, 1), m::NN)::RN
    CQ(multiply_m(x.size))
end

function divide_obj(x::CQ=CQ(1, 1), n::NN, m::NN)::RN
    CQ(divide_n_m(x.size))
end


function RN_add(x::RN, y::RN)
    NullNumber
end
function RN_subtract(x::RN, y::RN)
    RN(arg1.numerator - arg2.numerator, arg1.denominator - arg2.denominator)
end
function RN_compare(x::RN, y::RN)
    nn_intrusion_compare(arg1, arg2, operator)
end

infinite_divisibility_space = infinite