using Plots 

# include("full_language.jl")
tab = "  "
abstract type Task end
abstract type RationalNumberTask <: Task end 
abstract type ContinuousMatterTask <: Task end 
abstract type GetToZeroTask end

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

struct GetToZeroRationals <: GetToZeroTask
    input::Nothing 
    output::Bool
end

struct ArithmeticProblem <: RationalNumberTask
    input::Tuple{Number, Number, Symbol}
    output::Number
end

struct HalveDoubleProblem <: RationalNumberTask
    input::Tuple{Number, Symbol}
    output::Number
end

# continuous theory of matter tasks

struct GetToZeroSpace <: GetToZeroTask 
    input::Nothing 
    output::Bool
end

struct GetToZeroMatter <: GetToZeroTask 
    input::Nothing 
    output::Bool
end

function evaluate_task(task::NumbersBetweenZeroOne)
    relate
end

function evaluate_task(task::ArithmeticProblem)
    r1, r2, op = task.input 
    correct_equals(Base.invokelatest(eval(op), r1, r2), task.output)
end

function evaluate_task(task::HalveDoubleProblem)
    r, op = task.input 
    correct_equals(Base.invokelatest(eval(op), r), task.output)
end

function evaluate_task(task::GetToZeroTask, coarseness)
    if coarseness == infinite
        true
    elseif coarseness == fine
        0.5
    else
        false
    end
end

function evaluate_task(task::GetToZeroRationals)
    evaluate_task(task, infinite_divisibility_number)
end

function evaluate_task(task::GetToZeroSpace)
    evaluate_task(task, infinite_divisibility_space)
end

function evaluate_task(task::GetToZeroMatter)
    evaluate_task(task, infinite_divisibility_weight)
end

function correct_equals(x::Number, y::Number)
    cast_float(RationalNumber(x)) == cast_float(RationalNumber(y))
end

halve_task = HalveDoubleProblem((RN(1), :halve), RN(1, 2))
double_task = HalveDoubleProblem((RN(1, 2), :double), RN(1))

split_task = ArithmeticProblem((RN(1), NN(3), :divide), RN(1, 3))
combine_task = ArithmeticProblem((RN(1, 3), NN(3), :multiply), RN(1))
divide_task = ArithmeticProblem((NN(2), NN(3), :divide), RN(2, 3))

is_a_number_task = NumbersBetweenZeroOne(nothing, true)

arithmetic_task = ArithmeticProblem((RN(1, 3), RN(1, 3), :+), RN(2, 3))

get_to_zero_space_task = GetToZeroSpace(nothing, true)
get_to_zero_rationals_task = GetToZeroRationals(nothing, true)
get_to_zero_weight_task = GetToZeroMatter(nothing, true)

tasks = [
    # lang 2
    halve_task,
    double_task,
    # lang 3
    split_task,
    combine_task,
    divide_task,
    # lang 4
    is_a_number_task,
    # lang 5
    arithmetic_task,
    # lang 6
    get_to_zero_space_task,
    get_to_zero_space_task,
    # lang 7
    get_to_zero_rationals_task,
    get_to_zero_weight_task,
]

format_dict = Dict([:divide => :÷, :multiply => :*])
function format(op)
    if op in keys(format_dict)
        format_dict[op]
    else
        op
    end
end


function compute_score(lang_name, tasks)
    println(lang_name)
    include(lang_name)
    score = 0
    for task in tasks 
        println("$(tab)$(typeof(task))")
        if task isa ArithmeticProblem
            println("$(tab)$(join(map(x -> string(x), [task.input[1], format(task.input[3]), task.input[2]]), " "))")
        end
        s = evaluate_task(task)
        if (s isa Bool && s) || !(s isa Bool) && s == 1
            println("$(tab)correct!")
        else
            println("$(tab)incorrect!")
        end
        score += Float64(s)
    end
    println("$(tab)score: $(score)/$(length(tasks))")
    score 
end

languages = [
    "1_halving_doubling_physical_language.jl",
    "2_halving_doubling_notation_language.jl",
    "3_splitting_combining_dividing_notation_language.jl",
    "4_dividing_grounded_understanding_language.jl",
    "5_rational_arithmetic_understanding_language.jl",
    "6_space_infinite_divisibility_language.jl",
    "7_abstract_infinite_divisibility_language.jl"
]

scores = []
for language in languages 
    score = compute_score(language, tasks)
    push!(scores, score)
end

println("\nRESULTS\n")
for i in 1:length(languages)
    println(languages[i])
    println("$(tab)score: $(Float64(scores[i])) / $(Float64(length(tasks)))")
end

b = 2.0
c = 5.0
priors = Dict([
    "1_halving_doubling_physical_language.jl" => -1 * c,
    "2_halving_doubling_notation_language.jl" => -2 * c,
    "3_splitting_combining_dividing_notation_language.jl" => -3 * c,
    "4_dividing_grounded_understanding_language.jl" => -4 * c,
    "5_rational_arithmetic_understanding_language.jl" => -5 * c,
    "6_space_infinite_divisibility_language.jl" => -6 * c,
    "7_abstract_infinite_divisibility_language.jl" => -7 * c,
])

likelihoods = Dict(map(i -> languages[i] => scores[i], 1:length(languages)))

time_steps = 50

data = Dict(map(i -> languages[i] => [], 1:length(languages)))

for t in 1:time_steps 
    d = []
    for language in languages 
        x = b^(priors[language]) * (likelihoods[language])^t
        push!(d, x)
    end
    d = d ./ sum(d)
    
    for i in 1:length(languages)
        push!(data[languages[i]], d[i])
    end
end

# plot 
p = plot(1:time_steps, collect(1:time_steps) ./ time_steps, color="white", label=false)
for language in languages
    p = plot!(collect(1:time_steps), data[language], legend=:outerbottom, label=replace(language, ".jl" => "")) # legend=:outerbottom 
end

xlabel!("Training Data Volume", xguidefontsize=9)
ylabel!("Proportion", yguidefontsize=9)
title!("Relative Proportions of Rational Number / Continuous Matter LoTs", titlefontsize=10)

p