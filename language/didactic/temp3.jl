abstract type Number 
abstract type Operation 
Token = Char

struct NaturalNumber <: Number 
    value::Int
end






struct Divide <: Operation 
    arg1::NaturalNumber
    arg2::NaturalNumber
end

function format_op(op::Operation)::Union{Token, Vector{Token}} # CHANGES
    
end

function format_evaluated_op(op::Operation)::Token

end

# to-do: eval(op) definition -- changes over stages
# other thoughts: what about whole-number division, etc.

# unchanged
struct Add <: Operation 
    arg1::NaturalNumber
    arg2::NaturalNumber
end

struct Subtract <: Operation 
    arg1::NaturalNumber
    arg2::NaturalNumber
end

struct Multiply <: Operation 
    arg1::NaturalNumber
    arg2::NaturalNumber
end