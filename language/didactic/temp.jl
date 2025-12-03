# CHANGES: missing abstract number type
abstract type Relation 
Token = Char

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

function format_relation(r::Relation)::Union{Vector{Token}, Token} # CHANGES
    
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

# to-do: eval(op) definition -- changes over stages
# other thoughts: what about whole-number division, etc.