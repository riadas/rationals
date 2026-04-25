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
