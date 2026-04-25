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