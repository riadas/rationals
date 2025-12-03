abstract type Number # NEW: generalizes natural numbers and fractions
abstract type Relation 
Token = Char

struct NaturalNumber <: Number 
    value::Int
end

struct Fraction <: Number # NEW: ultimately recognized as a number
    numerator::NaturalNumber
    denominator::NaturalNumber
end

struct Divide <: Relation 
    arg1::Number
    arg2::Number
end

function format_relation(r::Relation)::Vector{Token} # NEW: consistent syntax
    
end

function format_evaluated_relation(r::Relation)::Token
    
end

# unchanged
struct Add <: Relation 
    arg1::Number
    arg2::Number
end

struct Subtract <: Relation 
    arg1::Number
    arg2::Number
end

struct Multiply <: Relation 
    arg1::Number
    arg2::Number
end