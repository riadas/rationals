include("full_language.jl")

abstract type Task end
abstract type RationalNumberTask <: Task end 
abstract type ContinuousMatterTask <: Task end 

# rational number tasks

struct NumbersBetweenZeroOne <: RationalNumberTask
    input::Nothing 
    output::Bool
end

struct HowManyNumbersBetweenZeroOne <: RationalNumberTask
    input::Nothing
    output::Coarseness
end

struct OrderFractions <: RationalNumberTask 
    input::Pair{RationalNumber}
    output::RationalNumber
end 

struct GetToZeroRationals <: RationalNumberTask
    input::Nothing 
    output::Bool
end

struct ArithmeticProblem <: RationalNumberTask
    input::Tuple{RationalNumber, RationalNumber, Symbol}
    output::RationalNumber
end

# continuous theory of matter tasks

struct GetToZeroSpace <: ContinuousMatterTask 
    input::Nothing 
    output::Bool
end

struct GetToZeroMatter <: ContinuousMatterTask 
    input::Nothing 
    output::Bool
end

function evaluate_task(task::ArithmeticProblem)
    r1, r2, op = task.input 
    Base.invokelatest(eval(op), r1, r2) == task.output
end

function evaluate_task(task::GetToZeroRationals)
    infinite_divisibility_number == infinite
end

arithmetic_task = ArithmeticProblem((RN(1, 3), RN(1, 3), :+), RN(2, 3))
get_to_zero_rationals_task = GetToZeroRationals(nothing, true)

tasks = [
    arithmetic_task,
    get_to_zero_rationals_task
]

score = 0
for task in tasks 
    println(typeof(task))
    if evaluate_task(task)
        global score += 1
        println("correct!")
    else
        println("incorrect!")
    end
end 

println("score: $(score)/$(length(tasks))")