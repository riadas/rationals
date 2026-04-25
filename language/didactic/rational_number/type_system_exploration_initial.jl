# TYPES

abstract type NumberSymbol end 
abstract type NaturalNumber <: NumberSymbol end 
abstract type RationalNumber <: NaturalNumber end # RNs are a special kind of NN

abstract type PhysicalQuantity end 

abstract type Operation end

PQ = PhysicalQuantity 

struct NN <: NaturalNumber # NN is concrete impl. of NaturalNumber
    value::Int
end

struct RN <: RationalNumber # RN is concrete impl. of RationalNumber
    num::NN 
    denom::NN
end

NN(a::RN) = NullNumber # UNKNOWN: RN <: NN casting is inconsistent

DQ = DiscreteQuantity 

@relate NN DiscreteQuantity

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

@relate RN Divide 
@relate RN Subtract (arg1 < arg2) # undifferentiated division/subtraction

include("type_system_casting_functions.jl")

# FUNCTIONS 

function next_word(x::NN)::NN
    NN(x + 1)
end

@relate (add_obj, DQ) (next_word, NN)

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
    eval(DQ(x, Subtract(n, n - 1))) # represent the discrete subtraction operation `(n - (n - 1)) = 1` using object x
end

function combine_obj(x::PQ=PQ(Hidden(RN(1, 1))), m::NN)::PQ
    eval(DQ(x, Add(1, m - 1))) # represent the discrete addition operation `1 + (m - 1) = m` using objects like x
end

function divide_obj(x::PQ=PQ(Hidden(RN(1, 1))), n::NN)::PQ
    combine_obj(split_obj(x, n), m) 
end

function NN_op(x::NN, y::NN, op::Symbol)
    eval(op)(x, y)
end

function RN_op(x::RN, y::RN, op::Symbol)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm / arg1.denominator)
    scaled_arg2 = scale(arg2, cm / arg2.denominator)
    RN(eval(op)(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

## sub-routines / helpers
function common_multiple(arg1::NN, arg2::NN)
    NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

function scale(rn::RN, nn::NN)
    RN(rn.numerator * nn, rn.denominator * nn, false)
end

NN_op(rn1::RN, rn2::RN) = NullNumber # UNKNOWN: RN_op <: NN_op casting is inconsistent, despite RN <: NN


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