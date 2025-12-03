# CHANGES: missing abstract number type
abstract type Relation 

abstract type Token # spaceless string
EntitySyntax = Token # 1, 2, 1.5, 1/2
RelationSyntax = Vector{Token} # 1 + 2, 1 - 2, 1 × 2, 1 ÷ 2 

struct Number # CHANGES: recogized as specifically natural number
    value::Int
end

struct Fraction <: Relation # CHANGES: initially viewed as relation 
    arg1::Number
    arg2::Number
end

struct Divide <: Relation 
    arg1::Number
    arg2::Number
end

# format relation
function format_relation(r::Relation)::Union{RelationSyntax, EntitySyntax} # CHANGES
    
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

# to-do: eval(op) definition -- changes over stages
# other thoughts: what about whole-number division, etc.