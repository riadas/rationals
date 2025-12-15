abstract type Number end
abstract type Relation end
abstract type SpatialObject end

relate = true

# concrete number types: NaturalNumber and RationalNumber
struct NaturalNumber <: Number
    value::Int
end

struct RationalNumber <: Number
    numerator::NaturalNumber
    denominator::NaturalNumber
    simplify::Bool
    function RationalNumber(n::NaturalNumber, d::NaturalNumber, s::Bool)
        !s ? new(n, d) : new(NaturalNumber(Int(n.value / gcd(n.value, d.value))), NaturalNumber(Int(d.value / gcd(n.value, d.value))))
        # n/d < 1/infinite_divisibility_number ? new(0, 1) : new(n, d)
    end
end

RationalNumber(n, d) = RationalNumber(n, d, true)

Base.string(nn::NaturalNumber) = "$(nn.value)"
Base.string(rn::RationalNumber) = "$(string(rn.numerator))/$(string(rn.denominator))" 

Base.show(io::IO, nn::NaturalNumber) = print(Base.string(nn))
Base.show(io::IO, rn::RationalNumber) = print(Base.string(rn))

NN(v) = NaturalNumber(v)
RN(n) = RN(n, 1)
RN(n, d) = RationalNumber(n, d)
cast_NN(rn::RationalNumber) = gcd(rn.numerator.value, rn.denominator.value) == rn.denominator.value ? NN(Int(rn.numerator.value / rn.denominator.value)) : rn
cast_int(nn::NaturalNumber) = nn.value 
cast_float(rn::RationalNumber) = cast_int(rn.numerator) / cast_int(rn.denominator) 

NullNumber = NN(-1)

# concrete relation types: Add, Subtract, Multiply, Divide, Compare
struct Add <: Relation
    arg1::Number
    arg2::Number
    operator::Symbol
end

struct Subtract <: Relation
    arg1::Number
    arg2::Number
    operator::Symbol
end

struct Multiply <: Relation
    arg1::Number
    arg2::Number
    operator::Symbol
end

struct Divide <: Relation
    arg1::Number
    arg2::Number
    operator::Symbol
end

struct Compare <: Relation 
    arg1::Number 
    arg2::Number 
    operator::Symbol
end

Add(arg1, arg2) = Add(arg1, arg2, :+)
Subtract(arg1, arg2) = Subtract(arg1, arg2, :-)
Multiply(arg1, arg2) = Multiply(arg1, arg2, :*)
Divide(arg1, arg2) = Divide(arg1, arg2, :÷)

Base.eval(r::Relation) = eval(r.operator)(r.arg1, r.arg2)

# number and relation syntax (format)

struct Token # spaceless string
    value::String
end

EntitySyntax = Token # 1, 2, 1.5, 1/2
RelationSyntax = Vector{Token} # 1 + 2, 1 - 2, 1 × 2, 1 ÷ 2

## token constructor
Tokenize(s::String) = occursin(" ", s) ? map(x -> Token(x), split(s, " ")) : Token(s)

function format_problem(r::Relation)::RelationSyntax
    [format_problem_LHS(r)..., Token("="), format_problem_RHS(r)]
end

function format_problem_LHS(r::Relation)::RelationSyntax
    Tokenize("(r.arg1) $(r.operator == :isequal ? "=" : r.operator) $(r.arg2)")
end

function format_problem_RHS(r::Relation)::EntitySyntax
    Tokenize("$(eval(r))")
end

# Natural Number Arithmetic
function add(arg1::NaturalNumber, arg2::NaturalNumber)::NaturalNumber
    NaturalNumber(arg1.value + arg2.value)
end

function subtract(arg1::NaturalNumber, arg2::NaturalNumber)::NaturalNumber
    arg1.value >= arg2.value ? NaturalNumber(arg1.value - arg2.value) : error("$(arg1.value) less than $(arg2.value)")
end

function multiply(arg1::NaturalNumber, arg2::NaturalNumber)::NaturalNumber
    NaturalNumber(arg1.value * arg2.value)
end

function divide_whole(arg1::NaturalNumber, arg2::NaturalNumber)::NaturalNumber
    arg1.value % arg2.value == 0 ? NaturalNumber(Int(arg1.value / arg2.value)) : error("not divisible")
end

function compare(arg1::NaturalNumber, arg2::NaturalNumber, operator::Symbol)
    eval(operator)(arg1.value, arg2.value)
end

# Typecasting Functions 

## NaturalNumber <-> Int
NaturalNumber(arg::NaturalNumber) = arg

add(arg1::NaturalNumber, arg2::Int) = add(arg1, NaturalNumber(arg2))
subtract(arg1::NaturalNumber, arg2::Int) = subtract(arg1, NaturalNumber(arg2))
multiply(arg1::NaturalNumber, arg2::Int) = multiply(arg1, NaturalNumber(arg2))
divide(arg1::NaturalNumber, arg2::Int) = divide(arg1, NaturalNumber(arg2))
compare(arg1::NaturalNumber, arg2::Int, operator::Symbol) = compare(arg1, NaturalNumber(arg2), operator)

add(arg1::Int, arg2::NaturalNumber) = add(NaturalNumber(arg1), arg2)
subtract(arg1::Int, arg2::NaturalNumber) = subtract(NaturalNumber(arg1), arg2)
multiply(arg1::Int, arg2::NaturalNumber) = multiply(NaturalNumber(arg1), arg2)
divide(arg1::Int, arg2::NaturalNumber) = divide(NaturalNumber(arg1), arg2)
compare(arg1::Int, arg2::NaturalNumber, operator::Symbol) = compare(NaturalNumber(arg1), arg2, operator)

Base.:(+)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = add(arg1, arg2)
Base.:(-)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = subtract(arg1, arg2)
Base.:(*)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = multiply(arg1, arg2)
Base.:(/)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = divide(arg1, arg2)
Base.:(÷)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = divide(arg1, arg2)

Base.:(<)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = compare(arg1, arg2, :<)
Base.:isequal(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = divide(arg1, :isequal)
Base.:(>)(arg1::Union{NaturalNumber, Int}, arg2::NaturalNumber) = compare(arg1, arg2, :>)

Base.:(+)(arg1::NaturalNumber, arg2::Int) = add(arg1, arg2)
Base.:(-)(arg1::NaturalNumber, arg2::Int) = subtract(arg1, arg2)
Base.:(*)(arg1::NaturalNumber, arg2::Int) = multiply(arg1, arg2)
Base.:(/)(arg1::NaturalNumber, arg2::Int) = divide(arg1, arg2)
Base.:(÷)(arg1::NaturalNumber, arg2::Int) = divide(arg1, arg2)

Base.:(<)(arg1::NaturalNumber, arg2::Int) = compare(arg1, arg2, :<)
Base.:isequal(arg1::NaturalNumber, arg2::Int) = divide(arg1, :isequal)
Base.:(>)(arg1::NaturalNumber, arg2::Int) = compare(arg1, arg2, :>)

## RationalNumber <-> NaturalNumber <-> Int
RationalNumber(arg1::Int, arg2::Int) = RationalNumber(NaturalNumber(arg1), NaturalNumber(arg2))
RationalNumber(arg1::NaturalNumber, arg2::Int) = RationalNumber(arg1, NaturalNumber(arg2))
RationalNumber(arg1::Int, arg2::NaturalNumber) = RationalNumber(NaturalNumber(arg1), arg2)

RationalNumber(arg::Int) = RationalNumber(NaturalNumber(arg), NaturalNumber(1))
RationalNumber(arg::NaturalNumber) = RationalNumber(arg, NaturalNumber(1))
RationalNumber(arg::RationalNumber) = arg

add(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = add(arg1, RationalNumber(arg2))
subtract(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = subtract(arg1, RationalNumber(arg2))
multiply(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = multiply(arg1, RationalNumber(arg2))
divide(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = divide(arg1, RationalNumber(arg2))
compare(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}, operator::Symbol) = compare(arg1, RationalNumber(arg2), operator)

add(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = add(RationalNumber(arg1), arg2)
subtract(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = subtract(RationalNumber(arg1), arg2)
multiply(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = multiply(RationalNumber(arg1), arg2)
divide(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = divide(RationalNumber(arg1), arg2)
compare(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber, operator::Symbol) = compare(RationalNumber(arg1), arg2, operator)

Base.:(+)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = add(RationalNumber(arg1), arg2)
Base.:(-)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = subtract(RationalNumber(arg1), arg2)
Base.:(*)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = multiply(RationalNumber(arg1), arg2)
Base.:(/)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = divide(RationalNumber(arg1), arg2)
Base.:(÷)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = divide(RationalNumber(arg1), arg2)

Base.:(>)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = compare(RationalNumber(arg1), arg2, :<)
Base.:isequal(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = compare(RationalNumber(arg1), arg2, :isequal)
Base.:(<)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = compare(RationalNumber(arg1), arg2, :>)

Base.:(+)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = add(arg1, RationalNumber(arg2))
Base.:(-)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = subtract(arg1, RationalNumber(arg2))
Base.:(*)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = multiply(arg1, RationalNumber(arg2))
Base.:(/)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = divide(arg1, RationalNumber(arg2))
Base.:(÷)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = divide(arg1, RationalNumber(arg2))

Base.:(<)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = compare(arg1, RationalNumber(arg2), :<)
Base.:isequal(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = compare(arg1, RationalNumber(arg2), :isequal)
Base.:(>)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = compare(arg1, RationalNumber(arg2), :>)

# physical realm functions
struct Hidden
    value
end

struct PhysicalObject <: SpatialObject
    volume::Union{RationalNumber, Hidden} 
    weight::Union{RationalNumber, Hidden}
end

struct AbstractUnit <: SpatialObject
    length::RationalNumber
end

PhysicalObject(size::Union{RationalNumber, Hidden}) = PhysicalObject(size, size)
PhysicalObject(size::Union{Int, NaturalNumber}) = PhysicalObject(RationalNumber(size))

NullObject = PhysicalObject(0)

# .size defaults to the space dimension for PhysicalObject: .volume
Base.getproperty(obj::SpatialObject, sym::Symbol) = sym == :size ? obj.volume : Base.getfield(obj, sym)

# .size defaults to the space dimension for AbstractUnit: .length
Base.getproperty(obj::AbstractUnit, sym::Symbol) = sym == :size ? obj.length : Base.getfield(obj, sym)

Base.:(/)(obj::SpatialObject, nn::NaturalNumber) = PhysicalObject(divide(obj.volume, nn), divide(obj.weight, nn))
Base.:(*)(obj::SpatialObject, nn::NaturalNumber) = PhysicalObject(multiply(obj.volume, nn), multiply(obj.weight, nn))

Base.:(/)(obj::SpatialObject, nn::Int) = /(obj, NaturalNumber(nn))
Base.:(*)(obj::SpatialObject, nn::Int) = *(obj, NaturalNumber(nn))

function halve_obj(obj::SpatialObject)::SpatialObject
    obj / 2
end

function split_obj(obj::SpatialObject, n::NaturalNumber)::SpatialObject
    obj / n
end

function double_obj(obj::SpatialObject)::SpatialObject
    obj * 2
end

function combine_obj(obj::SpatialObject, n::NaturalNumber)::SpatialObject
    obj * n
end

function divide_obj(obj::SpatialObject, keep::NaturalNumber, split::NaturalNumber)::SpatialObject
    combine_obj(split_obj(obj, split), keep)
end

# abstract number realm functions

function halve()
    RationalNumber(1, 2)
end

function halve(n::NaturalNumber)
    RationalNumber(n, 2)
end

function halve(rn::RationalNumber)
    RationalNumber(rn.numerator, rn.denominator * 2) # halve_obj(PhysicalObject(rn)).size
end

function double(rn::RationalNumber)
    RationalNumber(rn.numerator*2, rn.denominator)
end

function divide(n::NaturalNumber)
    RationalNumber(1, n)
end

function divide(rn::RationalNumber, n::NaturalNumber)
    RationalNumber(rn.numerator, rn.denominator * n) # split_obj(PhysicalObject(rn), n).size
end

function multiply(rn::RationalNumber, n::NaturalNumber)
    RationalNumber(rn.numerator*n, rn.denominator) # combine_obj(PhysicalObject(rn), n).size
end

function divide(n::NaturalNumber, m::NaturalNumber)
    # multiply(divide(NaturalNumber(1), m), n) # combine_obj(split_obj(PhysicalObject(1), m), n).size
    # RationalNumber(n, m) 
    cast_NN((divide_obj(PhysicalObject(1), n, m)).size)
end


# arithmetic operations over Rational Numbers

## sub-routines / helpers
function common_multiple(arg1::NaturalNumber, arg2::NaturalNumber)
    NaturalNumber(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

function scale(rn::RationalNumber, nn::NaturalNumber)
    RationalNumber(rn.numerator * nn, rn.denominator * nn, false)
end

## arithmetic
function add(arg1::RationalNumber, arg2::RationalNumber)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm / arg1.denominator)
    scaled_arg2 = scale(arg2, cm / arg2.denominator)
    RationalNumber(add(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

function subtract(arg1::RationalNumber, arg2::RationalNumber)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm / arg1.denominator)
    scaled_arg2 = scale(arg2, cm / arg2.denominator)
    RationalNumber(subtract(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

function compare(arg1::RationalNumber, arg2::RationalNumber, operator::Symbol)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm / arg1.denominator)
    scaled_arg2 = scale(arg2, cm / arg2.denominator)
    compare(arg1.numerator, arg2.numerator, operator) # eval(operator)(arg1.numerator.value / arg1.denominator.value, arg2.numerator.value / arg2.denominator.value)
end

function multiply(arg1::RationalNumber, arg2::RationalNumber)
    divide(multiply(arg1, arg2.numerator), arg2.denominator)
end

function divide(arg1::RationalNumber, arg2::RationalNumber)
    divide(multiply(arg1, arg2.denominator), arg2.numerator)
end

# WEIGHT/DENSITY
function weight(obj::PhysicalObject)
    undifferentiated_weight_density(obj)
end

function density(obj::PhysicalObject)
    undifferentiated_weight_density(obj)
end

function undifferentiated_weight_density(obj::PhysicalObject)
    sample([cast_float(obj.weight), cast_float(obj.weight) / cast_float(obj.volume)])
end

@enum Coarseness coarse=4 fine=1000 infinite=typemax(Int32) 
Base.:(/)(x, y::Coarseness) = x/Int(y)

infinite_divisibility_space = fine # start: fine
infinite_divisibility_number = fine # start: coarse
infinite_divisibility_weight = fine # start: coarse