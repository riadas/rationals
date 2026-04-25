abstract type NumberSymbol end 
abstract type PhysicalQuantity end 

# TYPES

struct NaturalNumber <: RationalNumber
    value::Int
end
NN = NaturalNumber

struct RationalNumber <: NumberSymbol 
    num::NaturalNumber 
    denom::NaturalNumber
end
RN = RationalNumber 

RN(a::NN) = RN(a, NN(1))

DQ = DiscreteQuantity 
CQ = ContinuousQuantity

struct DiscreteQuantity <: ContinuousQuantity 
    size::NaturalNumber
end

struct ContinuousQuantity <: PhysicalQuantity 
    size::RationalNumber
end

CQ(a::DQ) = CQ(RN(a, NN(1)))

include("type_system_casting_functions.jl")

# FUNCTIONS 

function next_word(x::NN)::NN
    NN(x + 1)
end

function add_obj(x::DQ)::DQ
    DQ(next_word(x.size))
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

function split_obj(x::CQ=CQ(RN(1, 1)), n::NN)::CQ
    CQ(divide_n(x.size, n))
end

function combine_obj(x::CQ=CQ(RN(1, 1)), m::NN)::CQ
    CQ(multiply_m(x.size, m))
end

function divide_obj(x::CQ=CQ(RN(1, 1)), n::NN)::CQ
    combine_obj(split_obj(x, n), m) 
    # CQ(divide_n_m(x.size, n, m)) 
end

function NN_op(x::NN, y::NN, op::Symbol)
    eval(op)(x, y)
end

## sub-routines / helpers
function common_multiple(arg1::NaturalNumber, arg2::NaturalNumber)
    NaturalNumber(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

@invariant = # =, +, -
function scale(rn::RationalNumber, nn::NaturalNumber)
    RationalNumber(rn.numerator * nn, rn.denominator * nn, false)
end

function RN_op(x::RN, y::RN, op::Symbol)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm / arg1.denominator)
    scaled_arg2 = scale(arg2, cm / arg2.denominator)
    RationalNumber(eval(op)(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end