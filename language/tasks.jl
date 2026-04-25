using Plots 
using BenchmarkTools
include("1_halving_doubling_physical_language.jl")
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
    output::Union{Number, Bool}
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
    actual_op = nothing
    # println(op)
    if op == :+ 
        actual_op = :add
    elseif op == :- 
        actual_op = :subtract
    elseif op == :* 
        actual_op = :multiply
    elseif op == :/
        actual_op = :divide
    elseif op in [:<, :isequal, :>]
        actual_op = :compare 
    else
        actual_op = op
    end

    if actual_op == :compare 
        correct_equals(Base.invokelatest(eval(actual_op), r1, r2, op), task.output)
    else
        correct_equals(Base.invokelatest(eval(actual_op), r1, r2), task.output)
    end
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

function correct_equals(x::Number, y::Bool)
    false
end

function correct_equals(x::Bool, y::Bool)
    println(x)
    println(y)
    x == y
end

halve_task = HalveDoubleProblem((RN(1), :halve), RN(1, 2))
double_task = HalveDoubleProblem((RN(1, 2), :double), RN(1))

split_task = ArithmeticProblem((RN(1), NN(3), :divide), RN(1, 3))
combine_task = ArithmeticProblem((RN(1, 3), NN(3), :multiply), RN(1))
divide_task = ArithmeticProblem((NN(2), NN(3), :divide), RN(2, 3))

is_a_number_task = NumbersBetweenZeroOne(nothing, true)

arithmetic_task = ArithmeticProblem((RN(1, 3), RN(1, 3), :+), RN(2, 3))
subtraction_task = ArithmeticProblem((RN(2, 3), RN(1, 2), :-), RN(1, 6))

compare_task = ArithmeticProblem((RN(1, 3), RN(1, 5), :<), false)

compare_task_bad = ArithmeticProblem((RN(1, 5), RN(2, 5), :<), true)

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

dataset = Dict([
    "halve_task" => (halve_task, 1),
    "double_task" => (double_task, 1),
    "split_task" => (split_task, 1),
    "combine_task" => (combine_task, 1),
    "divide_task" => (divide_task, 1),
    "is_a_number_task" => (is_a_number_task, 1),
    "arithmetic_task" => (arithmetic_task, 1),
    "compare_task" => (compare_task, 1),
    "get_to_zero_space_task" => (get_to_zero_space_task, 2),
    "get_to_zero_rationals_task" => (get_to_zero_rationals_task, 1),
    "get_to_zero_weight_task" => (get_to_zero_weight_task, 1),
])

format_dict = Dict([:divide => :÷, :multiply => :*])
function format(op)
    if op in keys(format_dict)
        format_dict[op]
    else
        op
    end
end


function compute_score(lang_name, dataset, dir_prefix="")
    num_tasks = sum(map(k -> dataset[k][2], [keys(dataset)...]))

    println(lang_name)
    if occursin("VARIANT", lang_name)
        include("$(dir_prefix)/didactic/rational_number/variants/$(lang_name)")
    else
        include("$(dir_prefix)/$(lang_name)")
    end
    score = 0
    for task_name in keys(dataset)
        task, task_count = dataset[task_name] 
        # println("$(tab)$(typeof(task))")
        # if task isa ArithmeticProblem
        #     println("$(tab)$(join(map(x -> string(x), [task.input[1], format(task.input[3]), task.input[2]]), " "))")
        # end
        s = evaluate_task(task)
        # if (s isa Bool && s) || !(s isa Bool) && s == 1
        #     println("$(tab)correct!")
        # else
        #     println("$(tab)incorrect!")
        # end
        score += Float64(s) * task_count
    end
    println("$(tab)score: $(score)/$(num_tasks)")
    score / num_tasks
end

function compute_computation_cost(lang_name, dataset, dir_prefix=""; eval_lang=true)
    num_tasks = sum(map(k -> dataset[k][2], [keys(dataset)...]))

    println(lang_name)
    if eval_lang 
        if occursin("VARIANT", lang_name)
            include("$(dir_prefix)/didactic/rational_number/variants/$(lang_name)")
        else
            include("$(dir_prefix)/$(lang_name)")
        end
    end
    score = 0
    for task_name in keys(dataset)
        task, task_count = dataset[task_name] 
        # println("$(tab)$(typeof(task))")
        # if task isa ArithmeticProblem
        #     println("$(tab)$(join(map(x -> string(x), [task.input[1], format(task.input[3]), task.input[2]]), " "))")
        # end
        _ = evaluate_task(task)
        benchmark_results = @btimed evaluate_task($task) seconds=0.1 samples=10
        # possible considerations: :time, :bytes, :alloc -- using just runtime (:time) for now
        runtime = benchmark_results.alloc
        # if (s isa Bool && s) || !(s isa Bool) && s == 1
        #     println("$(tab)correct!")
        # else
        #     println("$(tab)incorrect!")
        # end
        score += runtime * task_count
    end
    println("$(tab)computation cost: $(score)")
    score / num_tasks
end


# languages = [
#     "1_halving_doubling_physical_language.jl",
#     "2_halving_doubling_notation_language.jl",
#     "3_splitting_combining_dividing_notation_language.jl",
#     "4_dividing_grounded_understanding_language.jl",
#     "5_rational_arithmetic_understanding_language.jl",
#     "6_space_infinite_divisibility_language.jl",
#     "7_abstract_infinite_divisibility_language.jl"
# ]

# scores = []
# for language in languages 
#     score = compute_score(language, dataset)
#     push!(scores, score)
# end

# println("\nRESULTS\n")
# for i in 1:length(languages)
#     println(languages[i])
#     println("$(tab)score: $(Float64(scores[i])) / $(Float64(num_tasks))")
# end

# b = 2.0
# c = 5.0
# priors = Dict([
#     "1_halving_doubling_physical_language.jl" => -1 * c,
#     "2_halving_doubling_notation_language.jl" => -2 * c,
#     "3_splitting_combining_dividing_notation_language.jl" => -3 * c,
#     "4_dividing_grounded_understanding_language.jl" => -4 * c,
#     "5_rational_arithmetic_understanding_language.jl" => -5 * c,
#     "6_space_infinite_divisibility_language.jl" => -6 * c,
#     "7_abstract_infinite_divisibility_language.jl" => -7 * c,
# ])

# likelihoods = Dict(map(i -> languages[i] => scores[i], 1:length(languages)))

# time_steps = 50

# data = Dict(map(i -> languages[i] => [], 1:length(languages)))

# for t in 1:time_steps 
#     d = []
#     for language in languages 
#         x = b^(priors[language]) * (likelihoods[language])^t
#         push!(d, x)
#     end
#     d = d ./ sum(d)
    
#     for i in 1:length(languages)
#         push!(data[languages[i]], d[i])
#     end
# end

# # plot 
# p = plot(1:time_steps, collect(1:time_steps) ./ time_steps, color="white", label=false)
# for language in languages
#     p = plot!(collect(1:time_steps), data[language], legend=:outerbottom, label=replace(language, ".jl" => "")) # legend=:outerbottom 
# end

# xlabel!("Training Data Volume", xguidefontsize=9)
# ylabel!("Proportion", yguidefontsize=9)
# title!("Relative Proportions of Rational Number / Continuous Matter LoTs", titlefontsize=10)

# p

# initial and final language, individual task computation costs (normalized)

# function normalize(x, max_task_val, min_task_val)
#     (x - min_task_val) / (max_task_val - min_task_val)
# end

# language_names_pretty = language_names

# ps = []
# all_base_computation_costs = [old_base_computation_costs_memory, old_base_computation_costs_allocs]
# for i in 1:2
#     base_computation_costs = all_base_computation_costs[i]    
#     L0_task_vals = map(t -> base_computation_costs[language_names_pretty[2]][t], task_names)
#     L7_task_vals = map(t -> base_computation_costs[language_names_pretty[4]][t], task_names)
#     all_task_vals = vcat(L0_task_vals, L7_task_vals)
#     max_task_val = maximum(all_task_vals)
#     min_task_val = minimum(all_task_vals)

#     title = i == 1 ? "bytes" : "allocs"
#     normalized_L0_task_vals = map(x -> normalize(x, max_task_val, min_task_val), L0_task_vals)
#     normalized_L7_task_vals = map(x -> normalize(x, max_task_val, min_task_val), L7_task_vals)

#     p1 = bar(task_names, normalized_L0_task_vals, xrotation=305, title="$(title): initial")
#     p2 = bar(task_names, normalized_L7_task_vals, xrotation=305, title="$(title): final")

#     push!(ps, p1)
#     push!(ps, p2)
# end

# plot(ps..., layout=(2, 2), size=(1000, 1000), ylims=(0.0, 1.0), xguidefontsize=4)

# function normalize(x, max_task_val, min_task_val)
#     (x - min_task_val) / (max_task_val - min_task_val)
# end

# language_names_pretty = language_names

# ps = []
# plot_values = []
# all_base_computation_costs = [old_base_computation_costs_memory, old_base_computation_costs_allocs]
# for i in 1:2
#     base_computation_costs = all_base_computation_costs[i]
    
#     all_task_vals = vcat(map(l -> map(t -> base_computation_costs[l][t], task_names), language_names_pretty[2:end])...)
#     max_task_val = maximum(all_task_vals)
#     min_task_val = minimum(all_task_vals)

#     average_language_values = []
#     for language_name in language_names_pretty[2:end] 
#         task_vals = map(t -> base_computation_costs[language_name][t], task_names)
#         normalized_task_vals = map(x -> normalize(x, max_task_val, min_task_val), task_vals)
#         push!(average_language_values, mean(normalized_task_vals))
#     end
    
    
#     average_language_values = (average_language_values .- minimum(average_language_values)) ./ (maximum(average_language_values) - minimum(average_language_values))
#     push!(plot_values, average_language_values)

#     title = i == 1 ? "bytes" : "allocs"

#     p = bar(language_names, average_language_values, xrotation=305, title="$(title)")

#     push!(ps, p)
# end

# plot(ps..., layout=(2, 1), size=(1000, 500), ylims=(0.0, 1.0))

# ##
# costs_alloc = deepcopy(old_costs_alloc)
# costs_memory = deepcopy(old_costs_memory)


# costs_alloc = costs
# indices = [4, 6, 8, 9, 10, 14]
# scale = 1.0 # 0.05
# for i in indices 
#     costs_alloc[i] = scale * costs_alloc[i]
#     costs_memory[i] = scale * costs_memory[i]
# end

# p1 = bar(language_names[2:end], (costs_alloc .- minimum(costs_alloc)) / (maximum(costs_alloc) - minimum(costs_alloc)), title="alloc")
# p2 = bar(language_names[2:end], (costs_memory .- minimum(costs_memory)) / (maximum(costs_memory) - minimum(costs_memory)), title="bytes")

# plot(p1, p2, layout=(2, 1), size=(1000, 500), ylims=(0.0, 1.0))
