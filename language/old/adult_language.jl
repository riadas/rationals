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

function format_relation(r::Relation)::RelationSyntax # NEW: consistent syntax
    
end

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

# PHYSICAL REALM
struct Object 
    volume::Number
    weight::Number
end

function halve(obj::Object)::Object
    Object(obj.volume/2, obj.weight/2)
end

function divide(obj::Object, keep::Number, split::Number)
    Object(obj.volume*keep/split, obj.weight*keep/split)
end

infinite_divisibility_space = false # TODO: change to enum Coarseness (values: coarse, fine, infinite)

# ABSTRACT NUMBER REALM
function halve(num::Number)
    num/2 # halve(Object(num)).volume
end

function divide(numerator::Number, denominator::Number)
    numerator/denominator # divide(Object(1), numerator, denominator).volume
end

infinite_divisibility_number = false # TODO: change to enum Coarseness (values: coarse, fine, infinite)

# WEIGHT/DENSITY
function weight(obj::Object)
    obj.weight
end

function density(obj::Object)
    obj.weight / obj.volume
end

