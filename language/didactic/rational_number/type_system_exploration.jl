# TYPES

abstract type NumberSymbol end 
abstract type RationalNumber <: NumberSymbol end 
abstract type NaturalNumber <: RationalNumber end

abstract type PhysicalQuantity end 

abstract type Operation end

PQ = PhysicalQuantity 

struct NN <: NaturalNumber
    value::Int
end

struct RN <: NumberSymbol 
    num::NN 
    denom::NN
end

RN(a::NN) = RN(a, NN(1)) # consistent NN <: RN casting!

DQ = DiscreteQuantity 
CQ = ContinuousQuantity

@relate NN DiscreteQuantity
@relate RN ContinuousQuantity

struct Add <: Operation
    arg1::NumberSymbol
    arg2::NumberSymbol
    operator::Symbol
end

struct Subtract <: Operation
    arg1::NumberSymbol
    arg2::NumberSymbol
    operator::Symbol
end

struct Multiply <: Operation
    arg1::NumberSymbol
    arg2::NumberSymbol
    operator::Symbol
end

struct Divide <: Operation
    arg1::NumberSymbol
    arg2::NumberSymbol
    operator::Symbol
end

struct Compare <: Operation 
    arg1::NumberSymbol 
    arg2::NumberSymbol 
    operator::Symbol
end

Add(arg1, arg2) = Add(arg1, arg2, :+)
Subtract(arg1, arg2) = Subtract(arg1, arg2, :-)
Multiply(arg1, arg2) = Multiply(arg1, arg2, :*)
Divide(arg1, arg2) = Divide(arg1, arg2, :÷)

Base.eval(r::Relation) = eval(r.operator)(r.arg1, r.arg2)

@relate RN Divide # RN is both a number *and* an operation (divide); latter captured in this @relate

include("type_system_casting_functions.jl")

# FUNCTIONS 

function next_word(x::NN)
    NN(x + 1)
end

@relate (add_obj, DQ) (next_word, NN)

function divide_n(x::RN=RN(1, 1), n::NN)
    RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)
    RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)
    multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end

@relate (split_obj, CQ) (divide_n, RN) 
@relate (combine_obj, CQ) (multiply_m, RN) 
@relate (divide_obj, CQ) (divide_n_m, RN)

function NN_op(x::NN, y::NN, op::Symbol)
    eval(op)(x, y)
end

@generalize NN_op RN_op

## sub-routines / helpers
function common_multiple(arg1::NN, arg2::NN)
    NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

@invariant = # =, +, -
function scale(rn::RN, nn::NN)
    RN(rn.numerator * nn, rn.denominator * nn, false)
end

RN_op(nn1::NN, nn2::NN) = RN_op(RN(nn1, 1), RN(nn1, 1)) # consistent NN_op <: RN_op casting

function divide(n1::NN, n2::NN)
    remainder = n1 
    count = 0
    while remainder > 0 
        remainder -= n2
        count += 1
    end

    if remainder == 0 
        count
    else
        RN(count - 1, RN(remainder + n2, n2))
    end
end

# 1 and 2/3 = (1 * 3 + 2)/3
RN(x::NN, y::RN) = RN(x * y.denom + y.num, y.denom)