abstract type Number end
abstract type Relation end
abstract type Object end

# concrete number types: NaturalNumber and RationalNumber
struct NaturalNumber <: Number
    value::Int
end

struct RationalNumber <: Number
    numerator::NaturalNumber
    denominator::NaturalNumber
    # function RationalNumber(n, d)
    #     n/d < 1/infinite_divisibility_number ? new(0, 1) : new(n, d)
    # end
end

Base.string(nn::NaturalNumber) = "$(nn.value)"
Base.string(rn::RationalNumber) = "$(string(rn.numerator))/$(string(rn.denominator))" 

NN(v) = NaturalNumber(v)
RN(n, d) = RationalNumber(n, d)

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

Add(arg1, arg2) = Add(arg1, arg2, :+)
Subtract(arg1, arg2) = Subtract(arg1, arg2, :-)
Multiply(arg1, arg2) = Multiply(arg1, arg2, :*)
Divide(arg1, arg2) = Divide(arg1, arg2, :÷)

eval(r::Relation) = eval(Meta.parse(lowercase(string(typeof(r)))))(r.arg1, r.arg2)

# number and relation syntax (format)

struct Token # spaceless string
    value::String
end

EntitySyntax = Token # 1, 2, 1.5, 1/2
RelationSyntax = Vector{Token} # 1 + 2, 1 - 2, 1 × 2, 1 ÷ 2

## token constructor
Tokenize(s::String) = occursin(" ", s) ? map(x -> Token(x) split(s, " ")) : Token(s)

function format_problem(r::Relation)::RelationSyntax
    [format_problem_LHS(r)..., Token("="), format_problem_RHS(r)]
end

function format_problem_LHS(r::Relation)::RelationSyntax
    Tokenize("(r.arg1) $(r.operator) $(r.arg2)")
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

# Typecasting Functions 

## NaturalNumber <-> Int
NaturalNumber(arg::NaturalNumber) = arg

add(arg1::NaturalNumber, arg2::Int) = add(arg1, NaturalNumber(arg2))
subtract(arg1::NaturalNumber, arg2::Int) = subtract(arg1, NaturalNumber(arg2))
multiply(arg1::NaturalNumber, arg2::Int) = multiply(arg1, NaturalNumber(arg2))
divide_whole(arg1::NaturalNumber, arg2::Int) = divide(arg1, NaturalNumber(arg2))

add(arg1::Int, arg2::NaturalNumber) = add(NaturalNumber(arg1), arg2)
subtract(arg1::Int, arg2::NaturalNumber) = subtract(NaturalNumber(arg1), arg2)
multiply(arg1::Int, arg2::NaturalNumber) = multiply(NaturalNumber(arg1), arg2)
divide_whole(arg1::Int, arg2::NaturalNumber) = divide(NaturalNumber(arg1), arg2)

Base.:(+)(arg1::Union{NaturalNumber, Int}, arg2::Union{NaturalNumber, Int}) = arg1 isa Int && arg2 isa Int ? arg1 + arg2 : add(arg1, arg2)
Base.:(-)(arg1::Union{NaturalNumber, Int}, arg2::Union{NaturalNumber, Int}) = arg1 isa Int && arg2 isa Int ? arg1 - arg2 : subtract(arg1, arg2)
Base.:(*)(arg1::Union{NaturalNumber, Int}, arg2::Union{NaturalNumber, Int}) = arg1 isa Int && arg2 isa Int ? arg1 * arg2 : multiply(arg1, arg2)
Base.:(/)(arg1::Union{NaturalNumber, Int}, arg2::Union{NaturalNumber, Int}) = arg1 isa Int && arg2 isa Int ? arg1 / arg2 : divide_whole(arg1, arg2)
Base.:(÷)(arg1::Union{NaturalNumber, Int}, arg2::Union{NaturalNumber, Int}) = arg1 isa Int && arg2 isa Int ? arg1 ÷ arg2 : divide_whole(arg1, arg2)

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

add(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = add(RationalNumber(arg1), arg2)
subtract(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = subtract(RationalNumber(arg1), arg2)
multiply(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = multiply(RationalNumber(arg1), arg2)
divide(arg1::Union{NaturalNumber, Int}, arg2::RationalNumber) = divide(RationalNumber(arg1), arg2)

Base.:(+)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = add(RationalNumber(arg1), arg2)
Base.:(-)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = subtract(RationalNumber(arg1), arg2)
Base.:(*)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = multiply(RationalNumber(arg1), arg2)
Base.:(/)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = divide(RationalNumber(arg1), arg2)
Base.:(÷)(arg1::Union{RationalNumber, NaturalNumber, Int}, arg2::RationalNumber) = divide(RationalNumber(arg1), arg2)

Base.:(+)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = add(arg2, RationalNumber(arg2))
Base.:(-)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = subtract(arg2, RationalNumber(arg2))
Base.:(*)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = multiply(arg2, RationalNumber(arg2))
Base.:(/)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = divide(arg2, RationalNumber(arg2))
Base.:(÷)(arg1::RationalNumber, arg2::Union{NaturalNumber, Int}) = divide(arg2, RationalNumber(arg2))

# physical realm functions
struct PhysicalObject <: Object
    volume::RationalNumber 
    weight::RationalNumber
end

struct AbstractUnit <: Object
    length::RationalNumber=RN(1)
end

PhysicalObject(size::RationalNumber) = PhysicalObject(size, size)
PhysicalObject(size::Union{Int, NaturalNumber}) = PhysicalObject(RationalNumber(size))

# .size defaults to the space dimension for PhysicalObject: .volume
Base.getproperty(obj::Object, sym::Symbol) = sym == :size ? obj.volume : Base.getfield(obj, sym)

# .size defaults to the space dimension for AbstractUnit: .length
Base.getproperty(obj::AbstractUnit, sym::Symbol) = sym == :size ? obj.length : Base.getfield(obj, sym)

Base.:(/)(obj::Object, nn::NaturalNumber) = PhysicalObject(divide(obj.volume, nn), divide(obj.weight, nn))
Base.:(*)(obj::Object, nn::NaturalNumber) = PhysicalObject(multiply(obj.volume, nn), multiply(obj.weight, nn))

Base.:(/)(obj::Object, nn::Int) = /(obj, NaturalNumber(nn))
Base.:(*)(obj::Object, nn::Int) = *(obj, NaturalNumber(nn))

function halve_obj(obj::Object)::Object
    obj / 2
end

function split_obj(obj::Object, n::NaturalNumber)::Object
    obj / n
end

function combine_obj(obj::Object, n::NaturalNumber)::Object
    obj * n
end

function divide_obj(obj::Object, keep::NaturalNumber, split::NaturalNumber)::Object
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
    multiply(divide(NaturalNumber(1), m), n) # combine_obj(split_obj(PhysicalObject(1), m), n).size
    # RationalNumber(n, m) 
    # (divide_obj(PhysicalObject(1), n, m)).size
end

# arithmetic operations over Rational Numbers
function add(arg1::RationalNumber, arg2::RationalNumber)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm)
    scaled_arg2 = scale(arg2, cm)
    RationalNumber(add(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

function subtract(arg1::RationalNumber, arg2::RationalNumber)
    cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm)
    scaled_arg2 = scale(arg2, cm)
    RationalNumber(subtract(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

function multiply(arg1::RationalNumber, arg2::RationalNumber)
    divide(multiply(arg1, arg2.numerator), arg2.denominator)
end

function divide(arg1::RationalNumber, arg2::RationalNumber)
    divide(multiply(arg1, arg2.denominator), arg2.numerator)
end

function common_multiple(arg1::NaturalNumber, arg2::NaturalNumber)
    arg1 * arg2
end

function scale(rn::RationalNumber, nn::NaturalNumber)
    RationalNumber(rn.numerator * nn, rn.denominator * nn)
end

# WEIGHT/DENSITY
function weight(obj::PhysicalObject)
    obj.weight
end

function density(obj::PhysicalObject)
    obj.weight / obj.volume
end

@enum Coarseness coarse=4 fine=1000 infinite=typemax(Int32) 
Base.:(/)(x, y::Coarseness) = x/Int(y)

infinite_divisibility_space = fine
infinite_divisibility_number = coarse
infinite_divisibility_weight = coarse