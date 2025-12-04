abstract type Number # NEW: generalizes natural numbers and fractions
abstract type Relation 

abstract type Token # spaceless string
EntitySyntax = Token # 1, 2, 1.5, 1/2
RelationSyntax = Vector{Token} # 1 + 2, 1 - 2, 1 × 2, 1 ÷ 2 

struct NaturalNumber <: Number # NEW: subtype of number
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

# format relation
function format_relation(r::Relation)::RelationSyntax # NEW: consistent syntax
    
end

# format the (evaluated) output of a relation
function format_evaluated_relation(r::Relation)::EntitySyntax
    
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

