abstract type NumberSymbol end
abstract type PhysicalQuantity end
abstract type NaturalNumber <: NumberSymbol end
abstract type DiscreteQuantity <: PhysicalQuantity end

struct NN <: NaturalNumber
    value::Int
end

struct DQ <: DiscreteQuantity
    size::NN
end

function halve_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Subtract(n, n - 1)))
end

function double_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Add(1, m - 1)))
end