# include("../../tasks.jl")

# using Plots 
# using Combinatorics

# language_names = map(x -> "L$(x)", collect(1:8))

# language_names_pretty = [
#     "1_halving_doubling_physical_language.jl", 
#     "2_halving_doubling_notation_language.jl", 
#     "3_splitting_combining_dividing_notation_language.jl", 
#     "4_dividing_grounded_understanding_language.jl", 
#     "5_rational_arithmetic_understanding_language.jl", 
#     "6_space_infinite_divisibility_language.jl", 
#     "7_abstract_infinite_divisibility_language.jl",
#     "8_rational_arithmetic_ungrounded_language.jl",
#     ]

# base_language_definition_spec = Dict([
#     "halve1" => "RN(1, 2)",
#     "halve2" => "RN(n, 2)",
#     "halve3" => "RN(rn.numerator, rn.denominator * 2)",
#     "double" => "RN(rn.numerator*2, rn.denominator)",
#     "divide1" => "RN(1, n)",
#     "divide2" => "RN(rn.numerator, rn.denominator * n)",
#     "multiply" => "RN(rn.numerator*n, rn.denominator)",
#     "divide3" => "RN(n, m)",
#     # "common_multiple" => "NaturalNumber(lcm(arg1.value, arg2.value))",
#     # "scale" => "RN(rn.numerator * nn, rn.denominator * nn, false)",
#     "compare_op" => 
#         """
#         cm = common_multiple(arg1.denominator, arg2.denominator)
#         scaled_arg1 = scale(arg1, cast_NN(cm / arg1.denominator))
#         scaled_arg2 = scale(arg2, cast_NN(cm / arg2.denominator))
#         compare(arg1.numerator, arg2.numerator, operator)
#         """,
#     "add_op" => 
#         """
#         cm = common_multiple(arg1.denominator, arg2.denominator)
#         scaled_arg1 = scale(arg1, cast_NN(cm / arg1.denominator))
#         scaled_arg2 = scale(arg2, cast_NN(cm / arg2.denominator))
#         RN(add(scaled_arg1.numerator, scaled_arg2.numerator), cm)
#         """,
#     "subtract_op" => 
#         """
#         cm = common_multiple(arg1.denominator, arg2.denominator)
#         scaled_arg1 = scale(arg1, cast_NN(cm / arg1.denominator))
#         scaled_arg2 = scale(arg2, cast_NN(cm / arg2.denominator))
#         RN(subtract(scaled_arg1.numerator, scaled_arg2.numerator), cm)
#         """,
#     "multiply_op" => "RN(arg1.numerator * arg2.numerator, arg1.denominator * arg2.denominator)",
#     "divide_op" => "RN(arg1.numerator * arg2.denominator, arg1.denominator * arg2.numerator)",
#     "weight" => "obj.weight",
#     "density" => "obj.weight / obj.volume",
#     "infinite_divisibility_space" => "infinite",
#     "infinite_divisibility_number" => "infinite",
#     "infinite_divisibility_weight" => "infinite",
#     "relate" => "true",
# ])

# default_dict = Dict([
#     "halve1" => "NullNumber",
#     "halve2" => "NullNumber",
#     "halve3" => "NullNumber",
#     "double" => "NullNumber",
#     "divide1" => "NullNumber",
#     "divide2" => "NullNumber",
#     "multiply" => "NullNumber",
#     "divide3" => "NullNumber",
#     # "common_multiple" => "NaturalNumber(lcm(arg1.value, arg2.value))",
#     # "scale" => "RN(rn.numerator * nn, rn.denominator * nn, false)",
#     "compare_op" => "NullNumber",
#     "add_op" => "NullNumber",
#     "subtract_op" => "NullNumber",
#     "multiply_op" => "NullNumber",
#     "divide_op" => "NullNumber",
#     "weight" => "undifferentiated_weight_density(obj)",
#     "density" => "undifferentiated_weight_density(obj)",
#     "infinite_divisibility_space" => "fine",
#     "infinite_divisibility_number" => "coarse",
#     "infinite_divisibility_weight" => "coarse",
#     "relate" => "false",
# ])

# base_language_spec = Dict(map(k -> k => true, [keys(base_language_definition_spec)...]))

# # language specs for each language
# # LANGUAGE 1
# language1_definition_spec = deepcopy(base_language_definition_spec)
# language1_spec = deepcopy(base_language_spec)
# for k in keys(base_language_definition_spec)
#     language1_definition_spec[k] = default_dict[k]
#     language1_spec[k] = false
# end

# # LANGUAGE 2
# language2_definition_spec = deepcopy(base_language_definition_spec)
# language2_spec = deepcopy(base_language_spec)
# for k in keys(base_language_definition_spec)
#     if !(occursin("halve", k) || occursin("double", k))
#         language2_definition_spec[k] = default_dict[k]
#         language2_spec[k] = false
#     end
# end

# # LANGUAGE 3
# language3_definition_spec = deepcopy(base_language_definition_spec)
# language3_spec = deepcopy(base_language_spec)
# for k in keys(base_language_definition_spec)
#     if !(occursin("halve", k) || occursin("double", k) || k in ["divide1", "divide2", "divide3", "multiply"])
#         language3_definition_spec[k] = default_dict[k]
#         language3_spec[k] = false
#     end
# end

# # LANGUAGE 4
# language4_definition_spec = deepcopy(language3_definition_spec)
# language4_spec = deepcopy(language3_spec)
# language4_definition_spec["relate"] = "true"
# language4_spec["relate"] = true

# # LANGUAGE 5
# language5_definition_spec = deepcopy(language4_definition_spec)
# language5_spec = deepcopy(language4_spec)
# for k in keys(base_language_definition_spec)
#     if occursin("_op", k)
#         language5_definition_spec[k] = base_language_definition_spec[k]
#         language5_spec[k] = true
#     end
# end

# # LANGUAGE 6
# language6_definition_spec = deepcopy(language5_definition_spec)
# language6_spec = deepcopy(language5_spec)
# language6_definition_spec["infinite_divisibility_space"] = "infinite"
# language6_spec["infinite_divisibility_space"] = true

# # LANGUAGE 7
# language7_definition_spec = deepcopy(base_language_definition_spec)
# language7_spec = deepcopy(base_language_spec)

# # LANGUAGE 8 
# language8_definition_spec = deepcopy(language5_definition_spec)
# language8_spec = deepcopy(language5_spec)
# language8_definition_spec["relate"] = default_dict["relate"]
# language8_spec["relate"] = false

# language_name_to_definition_spec = Dict([
#     "1_halving_doubling_physical_language.jl" => language1_definition_spec, 
#     "2_halving_doubling_notation_language.jl" => language2_definition_spec, 
#     "3_splitting_combining_dividing_notation_language.jl" => language3_definition_spec, 
#     "4_dividing_grounded_understanding_language.jl" => language4_definition_spec, 
#     "5_rational_arithmetic_understanding_language.jl" => language5_definition_spec, 
#     "6_space_infinite_divisibility_language.jl" => language6_definition_spec, 
#     "7_abstract_infinite_divisibility_language.jl"  => language7_definition_spec,
#     "8_rational_arithmetic_ungrounded_language.jl"  => language8_definition_spec,
# ])

# language_name_to_spec = Dict([
#     "1_halving_doubling_physical_language.jl" => language1_spec, 
#     "2_halving_doubling_notation_language.jl" => language2_spec, 
#     "3_splitting_combining_dividing_notation_language.jl" => language3_spec, 
#     "4_dividing_grounded_understanding_language.jl" => language4_spec, 
#     "5_rational_arithmetic_understanding_language.jl" => language5_spec, 
#     "6_space_infinite_divisibility_language.jl" => language6_spec, 
#     "7_abstract_infinite_divisibility_language.jl"  => language7_spec,
#     "8_rational_arithmetic_ungrounded_language.jl"  => language8_spec,
# ])


# selected_NN_intrusions_dict = Dict([
#     "compare_op" => "nn_intrusion_compare(arg1, arg2, operator)",
#     "add_op" => "RN(arg1.numerator + arg2.numerator, arg1.denominator + arg2.denominator)",
#     "subtract_op" => "RN(arg1.numerator - arg2.numerator, arg1.denominator - arg2.denominator)",
# ])

# function generate_selected_languages(intrusions=["compare_op", "add_op", "subtract_op"])
#     # original 8 specs, plus modifications to specs 5-8: for each, the 3^3 NN/UN versions
#     base_language_names_to_modify = [
#         "5_rational_arithmetic_understanding_language.jl", 
#         "6_space_infinite_divisibility_language.jl", 
#         "7_abstract_infinite_divisibility_language.jl",
#         "8_rational_arithmetic_ungrounded_language.jl",
#     ]
    
#     new_language_name_to_definition_spec = Dict()
#     new_language_name_to_spec = Dict()
#     for name in language_names_pretty 
#         new_language_name_to_definition_spec[name] = deepcopy(language_name_to_definition_spec[name])
#         new_language_name_to_spec[name] = Dict()

#         for k in keys(language_name_to_spec[name])
#             if language_name_to_spec[name][k]
#                 new_language_name_to_spec[name][k] = "RN"
#             else
#                 new_language_name_to_spec[name][k] = "UN"
#             end
#         end

#     end

#     options = ["UN", "NN", "RN"]
#     option_combos = [Iterators.product(options, options, options)...]
#     filter!(c -> !(c in [("UN", "UN", "UN"), ("RN", "RN", "RN")]), option_combos)

#     new_language_names = []
#     for language_name in base_language_names_to_modify
#         for combo_index in 1:length(option_combos)
#             option_combo = option_combos[combo_index] 
#             base_definition_spec = deepcopy(language_name_to_definition_spec[language_name])
#             base_spec = deepcopy(new_language_name_to_spec[language_name])
#             for i in 1:length(option_combo)
#                 function_name = intrusions[i]
#                 option_name = option_combo[i]
#                 if option_name == "NN"
#                     function_definition = selected_NN_intrusions_dict[function_name]
#                 elseif option_name == "UN"
#                     function_definition = default_dict[function_name]
#                 else
#                     function_definition = base_language_definition_spec[function_name]
#                 end
#                 base_definition_spec[function_name] = function_definition
#                 base_spec[function_name] = option_name
#             end
#             new_language_name = "VARIANT_$(combo_index)_$(language_name)"
#             push!(new_language_names, new_language_name)
#             new_language_name_to_definition_spec[new_language_name] = base_definition_spec
#             new_language_name_to_spec[new_language_name] = base_spec

#             # generate file
#             generate_language_file(new_language_name, new_language_name_to_definition_spec)
#         end        
#     end
#     all_language_names = [language_names_pretty..., new_language_names...]
#     (all_language_names, new_language_name_to_definition_spec, new_language_name_to_spec)
# end

# function generate_language_file(language_name, language_name_to_definition_spec)
#     language_template = read("language/didactic/rational_number/language_template.jl", String)
#     definition_spec = language_name_to_definition_spec[language_name]

#     for k in keys(definition_spec)
#         function_definition = definition_spec[k]
#         if function_definition == ""
#             function_definition = default_dict[k]
#         end
#         language_template = replace(language_template, "[$(k)]" => function_definition)
#     end

#     open("language/didactic/rational_number/variants/$(language_name)", "w+") do f 
#         write(f, language_template)
#     end
# end

# language_names_pretty, language_name_to_definition_spec, language_name_to_spec = generate_selected_languages()
# language_names = map(x -> "L$(x)", collect(1:length(language_names_pretty)))

# # COST COMPUTATION
# function compute_complexity_cost(language)
#     lang_spec = language_name_to_spec[language]
#     lang_definition_spec = language_name_to_definition_spec[language]
#     sum(map(k -> compute_complexity_cost(k, lang_spec, lang_definition_spec), [keys(lang_spec)...]))
# end

# function compute_complexity_cost(k, lang_spec, lang_definition_spec)
#     lang_spec[k] != "UN" ? length(split(lang_definition_spec[k], "")) : 0 # lang_spec[k] ? 1 : 0
# end

# function compute_parsimony_cost(language)
#     lang_spec = language_name_to_spec[language]
#     sum(map(k -> compute_parsimony_cost(k, lang_spec), [keys(lang_spec)...]))
# end

# function compute_parsimony_cost(k, lang_spec)
#     cost = 0
#     if lang_spec["relate"] != "RN" && !(k in ["multiply_op", "divide_op"])
#         cost += 1 # 100
#     end
#     cost
# end

# # UTILITY COMPONENT 1/2
# function compute_representation_cost(language)
#     compute_complexity_cost(language) + compute_parsimony_cost(language)
# end

# # ACCURACY COMPUTATION
task_dict = Dict([
    "halve_task" => (halve_task, 10),
    "double_task" => (double_task, 10),
    "split_task" => (split_task, 5),
    "combine_task" => (combine_task, 5),
    "divide_task" => (divide_task, 5),
    "is_a_number_task" => (is_a_number_task, 30), # MODIFY
    "arithmetic_task" => (arithmetic_task, 5), # MODIFY
    "subtraction_task" => (subtraction_task, 5),
    "compare_task" => (compare_task, 5),
    "get_to_zero_space_task" => (get_to_zero_space_task, 5),
    "get_to_zero_rationals_task" => (get_to_zero_rationals_task, 1),
    "get_to_zero_weight_task" => (get_to_zero_weight_task, 0),
])
relate_task_proportion = task_dict["is_a_number_task"][2] / sum(map(k -> task_dict[k][2], [keys(task_dict)...]))

function compute_task_accuracy_base(lang_name, task_dict)
    compute_score(lang_name, task_dict, "../..")
end

# base_accuracies = Dict()
# for language_name in language_names_pretty 
#     base_accuracies[language_name] = Dict()
#     for task_name in keys(task_dict)
#         atom_task_dict = Dict()
#         atom_task_dict[task_name] = (task_dict[task_name][1], 1)
#         accuracy = compute_task_accuracy_base(language_name, atom_task_dict)
#         base_accuracies[language_name][task_name] = accuracy
#     end
# end

# UTILITY COMPONENT 2/2
function compute_task_accuracy_efficient(lang_name, task_dict)
    if lang_name in keys(base_accuracies)
        score = 0.0 
        total_tasks = sum(map(k -> task_dict[k][2], [keys(task_dict)...]))
        for task_name in keys(task_dict)
            num_tasks = task_dict[task_name][2]
            accuracy = base_accuracies[lang_name][task_name]
            score += accuracy * num_tasks
        end
        score / total_tasks
    else
        compute_score(lang_name, task_dict, "../..")
    end
end

# language_names = language_names[1:8]
# language_names_pretty = language_names_pretty[1:8]

# FINAL ACCURACIES
accuracies = []
for language_name in language_names_pretty 
    push!(accuracies, compute_task_accuracy_efficient(language_name, task_dict))
end
# accuracies[1] = 0.0

# FINAL COSTS
memory_costs = []
for language in language_names_pretty
    cost = compute_representation_cost(language)
    push!(memory_costs, cost)
end
# memory_costs[7] = 10 * memory_costs[7]
memory_costs = memory_costs ./ (maximum(memory_costs) / 2)
memory_costs[7] = 1.1 * memory_costs[7]
# memory_costs[6] = 1.5 * memory_costs[6]
# memory_costs[5] = 0.5 * memory_costs[5]

computational_costs = map(x -> 0.5, 1:length(language_names))

accuracy_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty[1:8]), accuracies[1:8], color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Accuracy", title="Task Accuracy", ylims=(0.0, 1.0))

memory_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty[1:8]), memory_costs[1:8], color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Memory Cost", ylims=(0.0, 1.0))

computation_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty[1:8]), computational_costs[1:8], color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Computation Cost", ylims=(0.0, 1.0))

plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))


# INFERENCE AND PLOTTING
function compute_utility(language_index, t)
    gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)
end

time_step_unit = 0.0001
num_time_steps = 500

gamma_c = 2.0
cost_c = 0.01
x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit * 1/5)
line_plot = nothing 
yvals_dict = Dict()
for i in 1:length(language_names)
    y_vals = map(x -> gamma_c*x*accuracies[i] - cost_c *(memory_costs[i] + computational_costs[i] - 0.50), x_vals)
    if isnothing(line_plot)
        global line_plot = plot(x_vals, y_vals, size=(600, 450), xlims=(0.0, 0.01), ylims=(-0.0085, 0.0115), legend=false, label=replace(join(split(language_names_pretty[i], "_")[2:end], " "), "language.jl" => ""), title="Utility vs. Cost Tolerance (Time)", xlabel="Cost Tolerance (Time)", ylabel="Utility")
    else
        global line_plot = plot(line_plot, x_vals, y_vals, size=(600, 450),  xlims=(0.0, 0.01), ylims=(-0.0085, 0.0115), legend=false, label=replace(join(split(language_names_pretty[i], "_")[2:end], " "), "language.jl" => ""), title="Utility vs. Cost Tolerance (Time)",  xlabel="Cost Tolerance (Time)", ylabel="Utility")
    end
    yvals_dict[i] = y_vals
end

max_indexes = []
maxs = []
for i in 1:length(x_vals) 
    vals = map(arr -> arr[i], map(n -> yvals_dict[n], 1:length(language_names)))
    # println(vals)
    index = findall(v -> v == maximum(vals), vals)[1]
    push!(max_indexes, index)
    push!(maxs, replace(join(split(language_names_pretty[index], "_")[2:end], " "), "language.jl" => ""))
    # println(maxs[end])
end

# line_plot

max_utility_plot = bar(ones(length(maxs)), color = map(i -> vcat(map(y -> collect(palette(:tab10)), 1:20)...)[i], max_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))
# line_plot


# BACKGROUND PROPOSER
function distance_between_specs(spec1, spec2, relate_factor, spec2_taught=0.0)
    dist = 0
    for k in keys(spec1)
        if spec1[k] != spec2[k]
            dist += 1
        end
    end

    if spec1["relate"] != "RN" && spec2["relate"] == "RN"
        if foldl(&, map(x -> spec1[x] == "RN", ["halve1", "halve2", "halve3", "double", "divide1", "divide2", "divide3", "multiply"]), init=true)
            dist += 20 - 15 * relate_factor
        else
            dist += 100
        end
    end

    if spec1["infinite_divisibility_space"] != "RN" && spec2["infinite_divisibility_space"] == "RN"
        # dist += 10
        if spec1["relate"] != "RN"
            dist += 10
        else
            dist = dist / 10
        end
    end

    if spec1["infinite_divisibility_number"] != "RN" && spec2["infinite_divisibility_number"] == "RN"
        # dist += 10
        if spec1["relate"] != "RN"
            dist = dist * 100
        end

        if spec1["infinite_divisibility_space"] != "RN"
            dist = dist * 100
        else
            dist = dist / 10
        end
    end

    s = 0
    if dist != 0 
        if count(x -> x == "RN", collect(values(spec1))) > count(x -> x == "RN", collect(values(spec2)))
            s = 1 
        else
            s = -1
        end
    end

    dist = dist * instruction_bias_base^(1 - spec2_taught)

    (dist, s)
end

function forget_and_resynthesize_helper(distribution, t, instruction_bias=0.0, rederive_bool=true)
    new_distribution = deepcopy(distribution)
    for i in 1:length(distribution)
        if distribution[i] != 0
            lang_name = language_names_pretty[i]
            lang_spec = language_name_to_spec[lang_name]
            if lang_spec["relate"] != "RN" && (lang_spec["compare_op"] == "RN" || lang_spec["add_op"] == "RN" || lang_spec["subtract_op"] == "RN")
                function_names = ["compare_op", "add_op", "subtract_op"]
                forgetting_possibility_indices = []
                for i in 1:length(function_names)
                    if lang_spec[function_names[i]] == "RN"
                        push!(forgetting_possibility_indices, i)
                    end
                end
                possible_combos = filter(x -> x != [], [combinations(forgetting_possibility_indices)...])
                overall_forgetting_prob = 0.0
                individual_function_forgetting_prob = pre_relate_mistake_prob_min + (t / (num_time_steps * time_step_unit)) * (post_relate_mistake_prob_max - pre_relate_mistake_prob_min)
                for combo in possible_combos 
                    forgetting_prob = individual_function_forgetting_prob^(length(combo))
                    if rederive_bool 
                        no_rederiv_factor = (0.05)^(length(function_names) - length(combo))
                    else
                        no_rederiv_factor = 1.0
                    end
                    final_forgetting_prob = forgetting_prob * no_rederiv_factor
                    overall_forgetting_prob += final_forgetting_prob
                    new_spec = deepcopy(lang_spec)
                    for i in combo 
                        new_spec[function_names[i]] = "NN"
                    end
                    new_lang_name = find_lang_name_with_spec(new_spec)
                    new_lang_name_idx = findall(x -> x == new_lang_name, language_names_pretty)[1]
                    
                    new_distribution[new_lang_name_idx] += distribution[i] * final_forgetting_prob
                end
                new_distribution[i] = distribution[i] * (1 - overall_forgetting_prob)
            end
        end
    end
    new_distribution # TODO: use instruction_bias
end

function update_dist_based_on_forgetting_and_resynthesis(distribution, t, instruction_bias=0.0)
    # VERSON 1: redistribute weight without proposal
    # new_distribution = forget_and_resynthesize_helper(distribution, t, instruction_bias, true)
    
    # VERSION 2: redistribute weight with proposal
    new_distribution = forget_and_resynthesize_helper(distribution, t, instruction_bias, false)
    new_distribution = compute_next_distribution(new_distribution, t, 0.0)
    new_distribution

    # VERSON 0: null
    # distribution
end

function find_lang_name_with_spec(spec)
    # println(spec)
    for lang_name in keys(language_name_to_spec)
        possible_spec = language_name_to_spec[lang_name]
        equal = true
        for k in keys(spec) 
            if spec[k] != possible_spec[k]
                equal = false 
                break
            end
        end
        if equal 
            return lang_name
        end
    end
    error("find_lang_name_with_spec: no lang_name with this spec found")
end

function plot_heatmap(relate_factor, title="", spec2_taught=0.0)
    transition_prob_identity = transition_prob_identity_base
    heatmap_values = []
    for i in 1:length(language_names)
        l1 = language_names_pretty[i] 
        push!(heatmap_values, [])
        for j in 1:length(language_names)
            l2 = language_names_pretty[j]
            l1_spec = language_name_to_spec[l1]
            l2_spec = language_name_to_spec[l2]
            dist, s = distance_between_specs(l1_spec, l2_spec, relate_factor, j < 9 ? (1.0 - spec2_taught) : 0.0)
            if dist == 0
                transition_prob = transition_prob_identity
            else
                if s == -1 
                    transition_prob = (1 - transition_prob_identity) * transition_prob_base^(-dist)
                else
                    transition_prob = 0
                end
            end
            push!(heatmap_values[end], transition_prob)
        end
        heatmap_values[end] = heatmap_values[end] ./ sum(heatmap_values[end])
    end

    heatmap_values_matrix = reshape(vcat(heatmap_values...), (length(language_names), length(language_names)))
    heatmap_values, heatmap(language_names, language_names, heatmap_values_matrix, aspect_ratio=:equal, clims=(0.0, 1.0), title=title, xrotation=270, tickfontsize=5, titlefontsize=11)
end

function compute_next_distribution(curr_distribution, t, spec2_taught=0.0)
    utility_sum = sum(map(x -> utility_base^(compute_utility(x, t)), 1:length(language_names)))
    
    relate_factor = t * relate_task_proportion * 1000
    relate_factor = relate_factor > 1 ? 1 : relate_factor
    push!(relate_factors, relate_factor)
    transition_probabilities, _ = plot_heatmap(relate_factor, "", spec2_taught)
    next_distribution = map(x -> 0.0, 1:length(language_names))
    for i in 1:length(language_names)
        total = 0.0
        utility = utility_base^(compute_utility(i, t)) / utility_sum
        for j in 1:length(language_names)
            transition_prob = transition_probabilities[j][i]
            total += transition_prob * utility * curr_distribution[j]
        end
        next_distribution[i] = total
    end
    next_distribution = next_distribution ./ sum(next_distribution)
    next_distribution
end

num_time_steps = 750
transition_prob_identity_base = 0.99
transition_prob_identity_rate = 0.0003
transition_prob_base = 2 # 100.0 2
utility_base = 10.0 # 10000.0
instruction_bias_base = 1000.0

pre_relate_mistake_prob_max = 0.3
pre_relate_mistake_prob_min = 0.2
post_relate_mistake_prob_max = 0.05
post_relate_mistake_prob_min = 0.01

max_lot_indexes = [1]
max_lots = [language_names_pretty[1]]
curr_distribution = map(x -> 0.0, 1:length(language_names))
curr_distribution[1] = 1.0
all_distributions = []
push!(all_distributions, curr_distribution)
relate_factors = []
for t in 0:time_step_unit:num_time_steps*time_step_unit
    next_distribution = compute_next_distribution(curr_distribution, t)

    # forgetting/rederivation-based modification of new distribution
    next_distribution = update_dist_based_on_forgetting_and_resynthesis(next_distribution, t)

    index = findall(v -> v == maximum(next_distribution), next_distribution)[1]
    push!(max_lot_indexes, index)
    push!(max_lots, join(split(language_names_pretty[index], "_")[2:end], " "))
    if max_lot_indexes[end] != max_lot_indexes[end - 1]
        println(t)
    end

    global curr_distribution = next_distribution
    # if curr_distribution[6] != 0
    #     println("hello 1")
    # end
    push!(all_distributions, curr_distribution)
    println(max_lots[end])

end

max_lot_plot = bar(ones(length(max_lots)), color = map(i -> vcat(map(y -> collect(palette(:tab10)), 1:20)...)[i], max_lot_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)


dist_plot = nothing
dist_xs = collect(0:time_step_unit:num_time_steps*time_step_unit)
dist_ys = []
for i in 1:length(language_names)
    println(i)
    global dist_ys = map(t -> all_distributions[t][i], 1:length(dist_xs))
    if isnothing(dist_plot)
        global dist_plot = plot(dist_xs, dist_ys, label=language_names_pretty[i], legend=false, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
    else
        global dist_plot = plot(dist_plot, dist_xs, dist_ys, label=language_names_pretty[i], legend=false, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
    end
end

max_lot_plot

# dist_plot

plot(dist_plot, max_lot_plot, layout=(2, 1))