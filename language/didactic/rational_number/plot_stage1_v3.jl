include("../../tasks.jl")

using Plots 
using Combinatorics
using JSON

language_names = map(x -> "L$(x)", collect(1:10))

language_names_pretty = [
    "1_halving_doubling_physical_language.jl", 
    "2_halving_doubling_notation_language.jl", 
    "3_splitting_combining_dividing_notation_language.jl", 
    "4_dividing_grounded_understanding_language.jl", 
    "5_rational_arithmetic_understanding_language.jl", 
    "6_space_infinite_divisibility_language.jl", 
    "7_abstract_infinite_divisibility_language.jl",
    "8_rational_arithmetic_ungrounded_language.jl",
    "9_number_infinite_divisibility_language.jl", 
    "10_matter_infinite_divisibility_language.jl", 
]

base_language_definition_spec = Dict([
    "halve1" => "RN(1, 2)",
    "halve2" => "RN(n, 2)",
    "halve3" => "RN(rn.numerator, rn.denominator * 2)",
    "double" => "RN(rn.numerator*2, rn.denominator)",
    "divide1" => "RN(1, n)",
    "divide2" => "RN(rn.numerator, rn.denominator * n)",
    "multiply" => "RN(rn.numerator*n, rn.denominator)",
    "divide3" => "RN(n, m)",
    # "common_multiple" => "NaturalNumber(lcm(arg1.value, arg2.value))",
    # "scale" => "RN(rn.numerator * nn, rn.denominator * nn, false)",
    "compare_op" => 
        """
        cm = common_multiple(arg1.denominator, arg2.denominator)
        scaled_arg1 = scale(arg1, cast_NN(cm / arg1.denominator))
        scaled_arg2 = scale(arg2, cast_NN(cm / arg2.denominator))
        compare(arg1.numerator, arg2.numerator, operator)
        """,
    "add_op" => 
        """
        cm = common_multiple(arg1.denominator, arg2.denominator)
        scaled_arg1 = scale(arg1, cast_NN(cm / arg1.denominator))
        scaled_arg2 = scale(arg2, cast_NN(cm / arg2.denominator))
        RN(add(scaled_arg1.numerator, scaled_arg2.numerator), cm)
        """,
    "subtract_op" => 
        """
        cm = common_multiple(arg1.denominator, arg2.denominator)
        scaled_arg1 = scale(arg1, cast_NN(cm / arg1.denominator))
        scaled_arg2 = scale(arg2, cast_NN(cm / arg2.denominator))
        RN(subtract(scaled_arg1.numerator, scaled_arg2.numerator), cm)
        """,
    "multiply_op" => "RN(arg1.numerator * arg2.numerator, arg1.denominator * arg2.denominator)",
    "divide_op" => "RN(arg1.numerator * arg2.denominator, arg1.denominator * arg2.numerator)",
    "weight" => "obj.weight",
    "density" => "obj.weight / obj.volume",
    "infinite_divisibility_space" => "infinite",
    "infinite_divisibility_number" => "infinite",
    "infinite_divisibility_weight" => "infinite",
    "relate" => "true",
])

default_dict = Dict([
    "halve1" => "NullNumber",
    "halve2" => "NullNumber",
    "halve3" => "NullNumber",
    "double" => "NullNumber",
    "divide1" => "NullNumber",
    "divide2" => "NullNumber",
    "multiply" => "NullNumber",
    "divide3" => "NullNumber",
    # "common_multiple" => "NaturalNumber(lcm(arg1.value, arg2.value))",
    # "scale" => "RN(rn.numerator * nn, rn.denominator * nn, false)",
    "compare_op" => "NullNumber",
    "add_op" => "NullNumber",
    "subtract_op" => "NullNumber",
    "multiply_op" => "NullNumber",
    "divide_op" => "NullNumber",
    "weight" => "undifferentiated_weight_density(obj)",
    "density" => "undifferentiated_weight_density(obj)",
    "infinite_divisibility_space" => "fine",
    "infinite_divisibility_number" => "coarse",
    "infinite_divisibility_weight" => "coarse",
    "relate" => "false",
])

base_language_spec = Dict(map(k -> k => true, [keys(base_language_definition_spec)...]))

# language specs for each language
# LANGUAGE 1
language1_definition_spec = deepcopy(base_language_definition_spec)
language1_spec = deepcopy(base_language_spec)
for k in keys(base_language_definition_spec)
    language1_definition_spec[k] = default_dict[k]
    language1_spec[k] = false
end

# LANGUAGE 2
language2_definition_spec = deepcopy(base_language_definition_spec)
language2_spec = deepcopy(base_language_spec)
for k in keys(base_language_definition_spec)
    if !(occursin("halve", k) || occursin("double", k))
        language2_definition_spec[k] = default_dict[k]
        language2_spec[k] = false
    end
end

# LANGUAGE 3
language3_definition_spec = deepcopy(base_language_definition_spec)
language3_spec = deepcopy(base_language_spec)
for k in keys(base_language_definition_spec)
    if !(occursin("halve", k) || occursin("double", k) || k in ["divide1", "divide2", "divide3", "multiply"])
        language3_definition_spec[k] = default_dict[k]
        language3_spec[k] = false
    end
end

# LANGUAGE 4
language4_definition_spec = deepcopy(language3_definition_spec)
language4_spec = deepcopy(language3_spec)
language4_definition_spec["relate"] = "true"
language4_spec["relate"] = true

# LANGUAGE 5
language5_definition_spec = deepcopy(language4_definition_spec)
language5_spec = deepcopy(language4_spec)
for k in keys(base_language_definition_spec)
    if occursin("_op", k)
        language5_definition_spec[k] = base_language_definition_spec[k]
        language5_spec[k] = true
    end
end

# LANGUAGE 6
language6_definition_spec = deepcopy(language5_definition_spec)
language6_spec = deepcopy(language5_spec)
language6_definition_spec["infinite_divisibility_space"] = "infinite"
language6_spec["infinite_divisibility_space"] = true

# LANGUAGE 7
language7_definition_spec = deepcopy(base_language_definition_spec)
language7_spec = deepcopy(base_language_spec)

# LANGUAGE 8 
language8_definition_spec = deepcopy(language5_definition_spec)
language8_spec = deepcopy(language5_spec)
language8_definition_spec["relate"] = default_dict["relate"]
language8_spec["relate"] = false

# NEW: LANGUAGE 9
language9_definition_spec = deepcopy(language5_definition_spec)
language9_spec = deepcopy(language5_spec)

language9_definition_spec["infinite_divisibility_number"] = "infinite"
language9_spec["infinite_divisibility_number"] = true

# NEW: LANGUAGE 10
language10_definition_spec = deepcopy(language5_definition_spec)
language10_spec = deepcopy(language5_spec)

language10_definition_spec["infinite_divisibility_weight"] = "infinite"
language10_spec["infinite_divisibility_weight"] = true

language_name_to_definition_spec = Dict([
    "1_halving_doubling_physical_language.jl" => language1_definition_spec, 
    "2_halving_doubling_notation_language.jl" => language2_definition_spec, 
    "3_splitting_combining_dividing_notation_language.jl" => language3_definition_spec, 
    "4_dividing_grounded_understanding_language.jl" => language4_definition_spec, 
    "5_rational_arithmetic_understanding_language.jl" => language5_definition_spec, 
    "6_space_infinite_divisibility_language.jl" => language6_definition_spec, 
    "7_abstract_infinite_divisibility_language.jl"  => language7_definition_spec,
    "8_rational_arithmetic_ungrounded_language.jl"  => language8_definition_spec,
    "9_number_infinite_divisibility_language.jl"  => language9_definition_spec,
    "10_matter_infinite_divisibility_language.jl"  => language10_definition_spec,
])

language_name_to_spec = Dict([
    "1_halving_doubling_physical_language.jl" => language1_spec, 
    "2_halving_doubling_notation_language.jl" => language2_spec, 
    "3_splitting_combining_dividing_notation_language.jl" => language3_spec, 
    "4_dividing_grounded_understanding_language.jl" => language4_spec, 
    "5_rational_arithmetic_understanding_language.jl" => language5_spec, 
    "6_space_infinite_divisibility_language.jl" => language6_spec, 
    "7_abstract_infinite_divisibility_language.jl"  => language7_spec,
    "8_rational_arithmetic_ungrounded_language.jl"  => language8_spec,
    "9_number_infinite_divisibility_language.jl"  => language9_spec,
    "10_matter_infinite_divisibility_language.jl"  => language10_spec,
])


selected_NN_intrusions_dict = Dict([
    "compare_op" => "nn_intrusion_compare(arg1, arg2, operator)",
    "add_op" => "RN(arg1.numerator + arg2.numerator, arg1.denominator + arg2.denominator)",
    "subtract_op" => "RN(arg1.numerator - arg2.numerator, arg1.denominator - arg2.denominator)",
])

function generate_selected_languages(intrusions=["compare_op", "add_op", "subtract_op"])
    # original 8 specs, plus modifications to specs 5-8: for each, the 3^3 NN/UN versions
    base_language_names_to_modify = [
        "5_rational_arithmetic_understanding_language.jl", 
        "6_space_infinite_divisibility_language.jl", 
        "7_abstract_infinite_divisibility_language.jl",
        "8_rational_arithmetic_ungrounded_language.jl",
    ]
    
    new_language_name_to_definition_spec = Dict()
    new_language_name_to_spec = Dict()
    for name in language_names_pretty 
        new_language_name_to_definition_spec[name] = deepcopy(language_name_to_definition_spec[name])
        new_language_name_to_spec[name] = Dict()

        for k in keys(language_name_to_spec[name])
            if language_name_to_spec[name][k]
                new_language_name_to_spec[name][k] = "RN"
            else
                new_language_name_to_spec[name][k] = "UN"
            end
        end

    end

    options = ["UN", "NN", "RN"]
    option_combos = [Iterators.product(options, options, options)...]
    filter!(c -> !(c in [("UN", "UN", "UN"), ("RN", "RN", "RN")]), option_combos)

    new_language_names = []
    for language_name in base_language_names_to_modify
        for combo_index in 1:length(option_combos)
            option_combo = option_combos[combo_index] 
            base_definition_spec = deepcopy(language_name_to_definition_spec[language_name])
            base_spec = deepcopy(new_language_name_to_spec[language_name])
            for i in 1:length(option_combo)
                function_name = intrusions[i]
                option_name = option_combo[i]
                if option_name == "NN"
                    function_definition = selected_NN_intrusions_dict[function_name]
                elseif option_name == "UN"
                    function_definition = default_dict[function_name]
                else
                    function_definition = base_language_definition_spec[function_name]
                end
                base_definition_spec[function_name] = function_definition
                base_spec[function_name] = option_name
            end
            new_language_name = "VARIANT_$(combo_index)_$(language_name)"
            push!(new_language_names, new_language_name)
            new_language_name_to_definition_spec[new_language_name] = base_definition_spec
            new_language_name_to_spec[new_language_name] = base_spec

            # generate file
            generate_language_file(new_language_name, new_language_name_to_definition_spec)
        end        
    end
    all_language_names = [language_names_pretty..., new_language_names...]
    (all_language_names, new_language_name_to_definition_spec, new_language_name_to_spec)
end

function generate_language_file(language_name, language_name_to_definition_spec)
    language_template = read("language/didactic/rational_number/language_template.jl", String)
    definition_spec = language_name_to_definition_spec[language_name]

    for k in keys(definition_spec)
        function_definition = definition_spec[k]
        if function_definition == ""
            function_definition = default_dict[k]
        end
        language_template = replace(language_template, "[$(k)]" => function_definition)
    end

    open("language/didactic/rational_number/variants/$(language_name)", "w+") do f 
        write(f, language_template)
    end
end

language_names_pretty, language_name_to_definition_spec, language_name_to_spec = generate_selected_languages()
language_names = map(x -> "L$(x)", collect(1:length(language_names_pretty)))

# COST COMPUTATION
function compute_complexity_cost(language)
    lang_spec = language_name_to_spec[language]
    lang_definition_spec = language_name_to_definition_spec[language]
    sum(map(k -> compute_complexity_cost(k, lang_spec, lang_definition_spec), [keys(lang_spec)...]))
end

function compute_complexity_cost(k, lang_spec, lang_definition_spec)
    scale_factor = occursin("infinite_divisibility", k) ? 10.0 : 1.0
    # lang_spec[k] != "UN" ? scale_factor * length(split(lang_definition_spec[k], "")) : 0 # lang_spec[k] ? 1 : 0
    lang_spec[k] != "UN" ? scale_factor * sum(map(x -> size(Meta.parse(x)), split(lang_definition_spec[k], "\n"))) : 0 # lang_spec[k] ? 1 : 0
end

function compute_parsimony_cost(language)
    lang_spec = language_name_to_spec[language]
    lang_spec["relate"] == "RN" ? 0.6 : 1.0
    # sum(map(k -> compute_parsimony_cost(k, lang_spec), [keys(lang_spec)...]))
end

function compute_parsimony_cost(k, lang_spec)
    # cost = 0
    # if lang_spec["relate"] != "RN" && !(k in ["multiply_op", "divide_op"])
    #     cost += 1 # 100
    # end
    # cost
end

# UTILITY COMPONENT 1/2
function compute_representation_cost(language)
    compute_complexity_cost(language) * compute_parsimony_cost(language)
end

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

# TEMPORARILY REMOVE VARIANTS
# language_names = language_names[1:10]
# language_names_pretty = language_names_pretty[1:10]

# INFERENCE AND PLOTTING
function compute_utility(language_index, t)
    gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)
end

# BACKGROUND PROPOSER
function distance_between_specs(spec1, spec2, relate_factor, spec2_taught=1.0)
    dist = 0
    spec2_lower_at_least_once = false
    for k in keys(spec1)
        if spec1[k] != spec2[k]
            # dist += 1
            if spec1[k] == "RN" || spec2[k] == "RN"
                dist += 1
            else
                dist += 0.5
            end

            if spec1[k] == "RN" && spec2[k] in ["NN", "UN"] # || spec1[k] == "NN" && spec2[k] == "UN"
                spec2_lower_at_least_once = true # spec1 is lower at least once
            end
        end
    end

    if spec1["relate"] != "RN" && spec2["relate"] == "RN"
        if foldl(&, map(x -> spec1[x] == "RN", ["halve1", "halve2", "halve3", "double", "divide1", "divide2", "divide3", "multiply"]), init=true)
            dist += 200 - 170 * relate_factor
        else
            dist = dist * 100
        end
    end

    if spec1["infinite_divisibility_space"] != "RN" && spec2["infinite_divisibility_space"] == "RN"
        # dist += 10
        if spec1["relate"] != "RN"
            dist += 10
        else
            # dist = dist / 10
        end
    end

    if spec1["infinite_divisibility_number"] != "RN" && spec2["infinite_divisibility_number"] == "RN"
        # dist += 10
        if spec1["relate"] != "RN"
            dist = dist * 100
        end

        if spec1["infinite_divisibility_space"] != "RN"
            dist = dist * 1000
        else
            dist = dist / 2.6
        end
    end

    if spec1["infinite_divisibility_weight"] != "RN" && spec2["infinite_divisibility_weight"] == "RN"
        # dist += 10
        if spec1["relate"] != "RN"
            dist = dist * 100
        end

        if spec1["infinite_divisibility_space"] != "RN"
            dist = dist * 1000
        else
            dist = dist / 2.6
        end
    end

    s = 0
    if dist != 0 
        if spec2_lower_at_least_once 
            s = 1 # no forgetting rule: spec1 would have to forget an RN definition to reach spec2
        else
            s = -1 
        end
        # if count(x -> x == "RN", collect(values(spec1))) > count(x -> x == "RN", collect(values(spec2)))
        #     s = 1 
        # else
        #     s = -1
        # end
    end

    dist = dist * instruction_bias_base^(1 - spec2_taught)

    (dist, s)
end

"""
                function_names = ["compare_op", "add_op", "subtract_op"]
                forgetting_possibility_indices = []
                for i in 1:length(function_names)
                    if lang_spec[function_names[i]] == "RN"
                        push!(forgetting_possibility_indices, i)
                    end
                end
                possible_combos = filter(x -> x != [], [combinations(forgetting_possibility_indices)...])
                forgetting_prob = 0.1 * (pre_relate_mistake_prob_max - (t / (num_time_steps * time_step_unit)) * (pre_relate_mistake_prob_max - pre_relate_mistake_prob_min))

                # individual_prob_ratios = map(x -> length(x) * (0.5)^(length(x)), possible_combos)
                individual_prob_ratios = ones(length(possible_combos)) 
                # if rederive_bool 
                #     individual_prob_ratios = map(i -> individual_prob_ratios[i] * (0.5)^(length(function_names) - length(possible_combos[i])), 1:length(possible_combos))
                # end
                individual_prob_ratios = (individual_prob_ratios ./ sum(individual_prob_ratios)) .* forgetting_prob

                for i in 1:length(possible_combos)
                    combo = possible_combos[i]
                    # individual_function_forgetting_prob = individual_prob_ratios[i]
                    # individual_function_forgetting_prob = forgetting_prob / length(possible_combos) 
                    # if individual_function_forgetting_prob != forgetting_prob / length(possible_combos) 
                    #     println("whattt")
                    #     println(possible_combos)
                    #     println(individual_function_forgetting_prob)
                    #     println(forgetting_prob / length(possible_combos) )
                    # end
                    individual_function_forgetting_prob = forgetting_prob / length(possible_combos)
                    if rederive_bool 
                        no_rederiv_factor = (0.5)^(length(function_names) - length(combo)) # (0.05)^(length(function_names) - length(combo))
                    else
                        no_rederiv_factor = 1.0
                    end
                    individual_function_forgetting_prob = individual_function_forgetting_prob * no_rederiv_factor
                    new_spec = deepcopy(lang_spec)
                    for i in combo 
                        new_spec[function_names[i]] = "NN"
                    end
                    new_lang_name = find_lang_name_with_spec(new_spec)
                    new_lang_name_idx = findall(x -> x == new_lang_name, language_names_pretty)[1]
                    
                    new_distribution[new_lang_name_idx] += distribution[i] * individual_function_forgetting_prob
"""

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
                forgetting_prob = 0.1 * (pre_relate_mistake_prob_max - (t / (num_time_steps * time_step_unit)) * (pre_relate_mistake_prob_max - pre_relate_mistake_prob_min))
                rederiv_factors = []
                #scale_factor = sum(map(combo -> length(combo) * (0.5)^(length(combo)), possible_combos))
                for combo in possible_combos 
                    individual_function_forgetting_prob = forgetting_prob / length(possible_combos)
                    if rederive_bool 
                        rederiv_factor = (0.5)^(length(function_names) - length(combo)) # * length(combo) * (0.5)^(length(combo)) / scale_factor
                    else
                        rederiv_factor = 1.0 # * length(combo) * (0.5)^(length(combo)) / scale_factor
                    end
                    push!(rederiv_factors, rederiv_factor)
                    individual_function_forgetting_prob = individual_function_forgetting_prob * rederiv_factor
                    new_spec = deepcopy(lang_spec)
                    for i in combo 
                        new_spec[function_names[i]] = "NN"
                    end
                    new_lang_name = find_lang_name_with_spec(new_spec)
                    new_lang_name_idx = findall(x -> x == new_lang_name, language_names_pretty)[1]
                    
                    new_distribution[new_lang_name_idx] += distribution[i] * individual_function_forgetting_prob
                end
                # arr = filter(x -> x > 1, new_distribution)
                # if arr != []
                #     println("OOPS")
                #     println(arr)
                #     println(sum(new_distribution))
                #         println(findall(x -> x > 1, new_distribution))
                # end

                # arr = filter(x -> x < 0, new_distribution)
                # if arr != []
                #     println("OOPS 2 BELOW ZERO")
                #     println(arr)
                #     println(findall(x -> x < 0, new_distribution))
                # end

                new_distribution[i] = distribution[i] * (1 - (forgetting_prob / length(possible_combos)) * sum(rederiv_factors))
            end
        end
    end
    new_distribution # TODO: use instruction_bias
end

function update_dist_based_on_forgetting_and_resynthesis(distribution, t, instruction_bias=0.0)
    # VERSON 1: redistribute weight without proposal 
    # new_distribution = forget_and_resynthesize_helper(distribution, t, instruction_bias, false)
    
    # VERSION 2: redistribute weight with proposal
    # # forgetting step: option A
    # new_distribution = forget_and_resynthesize_helper(distribution, t, instruction_bias, true) # FORGETTING AND RESYNTHESIS

    # # forgetting step: option B
    # new_distribution = compute_next_distribution(distribution, t, 0.0, true)
    
    # # rederivation step 
    # new_distribution = compute_next_distribution(new_distribution, t, 0.0, true) # false
    # new_distribution

    # arr = filter(x -> x > 1, new_distribution)
    # if arr != []
    #     println("2 OOPS")
    #     println(arr)
    #     println(sum(new_distribution))
    #         println(findall(x -> x > 1, new_distribution))
    # end

    # arr = filter(x -> x < 0, new_distribution)
    # if arr != []
    #     println("2 OOPS 2 BELOW ZERO")
    #     println(arr)
    #     println(findall(x -> x < 0, new_distribution))
    # end
    
    # new_distribution 

    # VERSON 0: null
    distribution # CURRENTLY RUNNING THIS VERSION
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

function plot_heatmap(relate_factor, title="", spec2_taught=1.0, backwards_bool=false)
    transition_prob_identity = transition_prob_identity_base
    heatmap_values = []
    for i in 1:length(language_names)
        l1 = language_names_pretty[i] 
        push!(heatmap_values, [])
        for j in 1:length(language_names)
            l2 = language_names_pretty[j]
            l1_spec = language_name_to_spec[l1]
            l2_spec = language_name_to_spec[l2]
            dist, s = distance_between_specs(l1_spec, l2_spec, relate_factor, j < 11 ? spec2_taught : 0.0)
            if dist == 0
                transition_prob = transition_prob_identity
            else
                if s == -1 
                    transition_prob = (1 - transition_prob_identity) * transition_prob_base^(-dist)
                else
                    if !backwards_bool
                        transition_prob = 0                        
                    else
                        transition_prob = 2 * (1 - transition_prob_identity) * transition_prob_base^(-dist)
                        w = 0.1
                        # transition_prob = ((1 - w) * transition_prob_identity + w * 1.0) - transition_prob_identity # 0.001
                    end
                end
            end
            push!(heatmap_values[end], transition_prob)
        end
        heatmap_values[end] = heatmap_values[end] ./ sum(heatmap_values[end])
    end

    heatmap_values_matrix = reshape(vcat(heatmap_values...), (length(language_names), length(language_names)))
    heatmap_values, heatmap(language_names, language_names, heatmap_values_matrix, aspect_ratio=:equal, clims=(0.0, 1.0), title=title, xrotation=270, tickfontsize=5, titlefontsize=12)
end

function compute_next_distribution(curr_distribution, t, spec2_taught=1.0, backwards_bool=false)
    utility_sum = sum(map(x -> utility_base^(compute_utility(x, t)), 1:length(language_names)))
    
    relate_factor = t * relate_task_proportion * 400
    relate_factor = relate_factor > 1 ? 1 : relate_factor
    push!(relate_factors, relate_factor)
    transition_probabilities, _ = plot_heatmap(relate_factor, "", spec2_taught, backwards_bool)
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

# # BASE ACCURACY COMPUTATION
# good curriculum
good_task_dict = Dict([
    "halve_task" => (halve_task, 10),
    "double_task" => (double_task, 10),
    "split_task" => (split_task, 5),
    "combine_task" => (combine_task, 5),
    "divide_task" => (divide_task, 5),
    "is_a_number_task" => (is_a_number_task, 25), # 15 vs. 0 MODIFY
    "arithmetic_task" => (arithmetic_task, 9), # MODIFY
    "subtraction_task" => (subtraction_task, 8),
    "compare_task" => (compare_task, 5),
    "compare_task_bad" => (compare_task_bad, 3),
    "get_to_zero_space_task" => (get_to_zero_space_task, 1),
    "get_to_zero_rationals_task" => (get_to_zero_rationals_task, 1),
    "get_to_zero_weight_task" => (get_to_zero_weight_task, 1),
])

# bad curriculum
bad_task_dict = Dict([
    "halve_task" => (halve_task, 10),
    "double_task" => (double_task, 10),
    "split_task" => (split_task, 5),
    "combine_task" => (combine_task, 5),
    "divide_task" => (divide_task, 5),
    "is_a_number_task" => (is_a_number_task, 1), # 15 vs. 0 MODIFY
    "arithmetic_task" => (arithmetic_task, 9), # MODIFY
    "subtraction_task" => (subtraction_task, 8),
    "compare_task" => (compare_task, 5),
    "compare_task_bad" => (compare_task_bad, 3),
    "get_to_zero_space_task" => (get_to_zero_space_task, 1),
    "get_to_zero_rationals_task" => (get_to_zero_rationals_task, 1),
    "get_to_zero_weight_task" => (get_to_zero_weight_task, 1),
])
test_name_to_task_dict = Dict(["good_curriculum" => good_task_dict, "bad_curriculum" => bad_task_dict])

task_groups = Dict([
    "1_halving_doubling_notation" => ["halve_task", "double_task"],
    "2_splitting_combining_dividing_notation" => ["split_task", "combine_task", "divide_task"],
    "3_dividing_physically_grounded_understanding" => ["is_a_number_task"],
    "4_arithmetic_memorization" => ["arithmetic_task", "subtraction_task", "compare_task", "compare_task_bad"],
    "5_infinite_divisibility" => ["get_to_zero_space_task", "get_to_zero_rationals_task", "get_to_zero_weight_task"],
])

original_colors = collect(palette(:tab10))
curriculum_plot_colors = [
    original_colors[2], 
    original_colors[3], 
    original_colors[4], 
    original_colors[8], 
    original_colors[7]
]

function plot_curriculum(test_name_, task_group_dict=task_groups, colors=curriculum_plot_colors)
    curriculum_dict = test_name_to_task_dict[test_name_]
    if test_name_ == "good_curriculum"
        title_prefix_modifier = "Understanding-Based"
        title_suffix_modifier = "(Analogy Driven)"
    else
        title_prefix_modifier = "Memorization-Based"
        title_suffix_modifier = "(Procedure Driven)"
    end

    task_group_names = sort(collect(keys(task_group_dict)))
    counts = map(group_name -> sum(map(task_name -> curriculum_dict[task_name][end], task_group_dict[group_name])), task_group_names)
    proportions = counts ./ sum(counts)
    scale = length(colors) == 2 ? 1 : 2
    curriculum_plot = bar(map(x -> join(split(x, "_")[2:end], "\n"), task_group_names), proportions, color = colors, size=(320 * scale, 525), bar_width=1, xlabel="Task Type", ylabel="Proportion", legend=false, titlefontsize=11, xtickfontsize=7, xguidefontsize=10, yguidefontsize=10, title="$(title_prefix_modifier) Curriculum\n$(title_suffix_modifier)", ylims=(0.0, 1.0))
end

function plot_all_curricula(subset=false)
    if subset 
        task_group_dict = Dict([
            "3_dividing_physically_grounded_understanding" => ["is_a_number_task"],
            "4_arithmetic_memorization" => ["arithmetic_task", "subtraction_task", "compare_task", "compare_task_bad"],
        ])
        colors = [
            collect(palette(:tab10))[4],
            collect(palette(:tab10))[8],
        ]
    else
        task_group_dict = task_groups
        colors = curriculum_plot_colors
    end
    good_curriculum_plot = plot_curriculum("good_curriculum", task_group_dict, colors)
    bad_curriculum_plot = plot_curriculum("bad_curriculum", task_group_dict, colors)
    
    scale = subset ? 1 : 2
    plot(good_curriculum_plot, bad_curriculum_plot, layout=(1, 2), size=(640 * scale, 525))
end

function compute_task_accuracy_base(lang_name, task_dict)
    compute_score(lang_name, task_dict, "../..")
end

# base_accuracies = Dict()
# for language_name in language_names_pretty 
#     base_accuracies[language_name] = Dict()
#     for task_name in keys(good_task_dict)
#         atom_task_dict = Dict()
#         atom_task_dict[task_name] = (good_task_dict[task_name][1], 1)
#         accuracy = compute_task_accuracy_base(language_name, atom_task_dict)
#         base_accuracies[language_name][task_name] = accuracy
#     end
# end

# PARAMS

# time step params
time_step_unit = 0.0001
num_time_steps = 2500 # 3000

# utility function params 
gamma_c = 2.0
cost_c = 0.03
utility_base = 9.0 # 10000.0
# gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)

# transition probability params
transition_prob_identity_base = 0.99
transition_prob_identity_rate = 0.0003
transition_prob_base = 2 # 100.0 2
instruction_bias_base = 100.0

# forgetting params (under forgetting model variant 1)
pre_relate_mistake_prob_max = 0.4
pre_relate_mistake_prob_min = 0.3
post_relate_mistake_prob_max = 0.05
post_relate_mistake_prob_min = 0.01

test_name = "bad_curriculum"
params_dict = Dict([
    "time_step_unit" => time_step_unit, 
    "num_time_steps" => num_time_steps,

    "gamma_c" => gamma_c,
    "cost_c" => cost_c,
    "utility_base" => utility_base,

    "transition_prob_identity_base" => transition_prob_identity_base,
    "transition_prob_identity_rate" => transition_prob_identity_rate,
    "transition_prob_base" => transition_prob_base,
    "instruction_bias_base" => instruction_bias_base,

    "pre_relate_mistake_prob_max" => pre_relate_mistake_prob_max,
    "pre_relate_mistake_prob_min" => pre_relate_mistake_prob_min,
    "post_relate_mistake_prob_max" => post_relate_mistake_prob_max,
    "post_relate_mistake_prob_min" => post_relate_mistake_prob_min,
    
    "forgetting_model_variant" => 2, # 1 2 3
    "test_name" => test_name
])

accuracies = []
memory_costs = []
computation_costs = []
relate_task_proportion = 0.0
relate_factors = []
all_distributions = []

function run_test(test_name_, save_fig_title="")
    global test_name = test_name_
    params_dict["test_name"] = test_name

    task_dict = test_name_to_task_dict[test_name]
    params_dict["curriculum"] = Dict(map(k -> k => task_dict[k][2], collect(keys(task_dict))))

    global relate_task_proportion = task_dict["is_a_number_task"][2] / sum(map(k -> task_dict[k][2], [keys(task_dict)...]))

    # FINAL ACCURACIES
    global accuracies = []
    for language_name in language_names_pretty 
        push!(accuracies, compute_task_accuracy_efficient(language_name, task_dict))
    end
    # accuracies[1] = 0.0

    # FINAL COSTS
    global memory_costs = []
    for language in language_names_pretty
        cost = compute_representation_cost(language)
        push!(memory_costs, cost)
    end
    # memory_costs[7] = 10 * memory_costs[7]
    memory_costs = memory_costs ./ (maximum(memory_costs) / 2)

    # memory_costs[4] = memory_costs[4] * 0.6 # grounded arithmetic
    # memory_costs[5] = memory_costs[5] * 0.6 # grounded arithmetic
    # memory_costs[6] = 1.15 * memory_costs[6] * 0.6 # space
    # memory_costs[7] = 1.15 * memory_costs[7] * 0.6 # all
    # memory_costs[8] = 1.2 * memory_costs[8] # ungrounded arithmetic

    # memory_costs[9] = 1.15 * memory_costs[9] * 0.6 # number
    # memory_costs[10] = 1.15 * memory_costs[10] * 0.6 # weight

    # for base_language_name in map(i -> language_names_pretty[i], 5:7)
    #     variant_language_name_idxs = findall(x -> occursin("VARIANT", x) && occursin(base_language_name, x), language_names_pretty)
    #     for i in variant_language_name_idxs 
    #         memory_costs[i] = 0.6 * memory_costs[i]
    #     end
    # end

    # for base_language_name in map(i -> language_names_pretty[i], 6:7)
    #     variant_language_name_idxs = findall(x -> occursin("VARIANT", x) && occursin(base_language_name, x), language_names_pretty)
    #     for i in variant_language_name_idxs 
    #         memory_costs[i] = 1.15 * memory_costs[i]
    #     end
    # end

    # for base_language_name in map(i -> language_names_pretty[i], 8)
    #     variant_language_name_idxs = findall(x -> occursin("VARIANT", x) && occursin(base_language_name, x), language_names_pretty)
    #     for i in variant_language_name_idxs 
    #         memory_costs[i] = 1.2 * memory_costs[i]
    #     end
    # end

    # memory_costs = memory_costs ./ (maximum(memory_costs) / 2)


    global computational_costs = map(x -> 0.5, 1:length(language_names))

    accuracy_plot = bar(map(x -> replace(join(split(x, "_")[2:end], " "), " language.jl" => ""), language_names_pretty[1:10]), accuracies[1:10], color = collect(palette(:tab10)), xrotation=305, size=(800, 525), legend=false, xlabel="LoT Stage", ylabel="Accuracy", title="Task Accuracy", ylims=(0.0, 1.0), xtickfontsize=6)

    memory_cost_plot = bar(map(x -> replace(join(split(x, "_")[2:end], " "), " language.jl" => ""), language_names_pretty[1:10]), memory_costs[1:10] ./ maximum(memory_costs[1:10]), color = collect(palette(:tab10)), xrotation=305, size=(800, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Memory Cost", ylims=(0.0, 1.0), xtickfontsize=6)

    computation_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty[1:10]), computational_costs[1:10], color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Computation Cost", ylims=(0.0, 1.0))

    plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))

    # UTILITY PLOTS
    x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit)
    line_plot = nothing 
    yvals_dict = Dict()
    max_yvals = 0.0
    min_yvals = 0.0
    for i in 1:length(language_names[1:10])
        y_vals = map(x -> gamma_c*x*accuracies[i] - cost_c *(memory_costs[i] + computational_costs[i] - 0.50), x_vals)
        max_yvals = maximum([max_yvals, maximum(y_vals)])
        min_yvals = minimum([min_yvals, minimum(y_vals)])

        if isnothing(line_plot)
            line_plot = plot(x_vals, y_vals, size=(600, 450), xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:bottomright, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = collect(palette(:tab10))[i], title="Utility vs. Cost Tolerance (Time)", xlabel="Cost Tolerance (Time)", ylabel="Utility")
        else
            line_plot = plot(line_plot, x_vals, y_vals, size=(600, 450),  xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:bottomright, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = collect(palette(:tab10))[i], title="Utility vs. Cost Tolerance (Time)",  xlabel="Cost Tolerance (Time)", ylabel="Utility")
        end
        yvals_dict[i] = y_vals
    end

    max_indexes = []
    maxs = []
    for i in 1:length(x_vals) 
        vals = map(arr -> arr[i], map(n -> yvals_dict[n], 1:length(language_names[1:10])))
        # println(vals)
        index = findall(v -> v == maximum(vals), vals)[1]
        push!(max_indexes, index)
        push!(maxs, replace(join(split(language_names_pretty[index], "_")[2:end], " "), "language.jl" => ""))
        # println(maxs[end])
    end

    # line_plot

    max_utility_plot = bar(ones(length(maxs)), color = map(i -> vcat(map(y -> collect(palette(:tab10)), 1:20)...)[i], max_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

    # plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))
    # line_plot

    # MAP LoT PLOTS

    max_lot_indexes = [1]
    max_lots = [language_names_pretty[1]]
    curr_distribution = map(x -> 0.0, 1:length(language_names))
    curr_distribution[1] = 1.0
    push!(all_distributions, curr_distribution)
    for t in 0:time_step_unit:num_time_steps*time_step_unit
        next_distribution = compute_next_distribution(curr_distribution, t, 1.0)

        # forgetting/rederivation-based modification of new distribution
        next_distribution = update_dist_based_on_forgetting_and_resynthesis(next_distribution, t)
        # println(length(next_distribution))
        # println(maximum(next_distribution))
        # @show next_distribution
        # println(maximum(next_distribution))
        index = findall(v -> v == maximum(next_distribution), next_distribution)[1]
        push!(max_lot_indexes, index)
        push!(max_lots, join(split(language_names_pretty[index], "_")[2:end], " "))
        if max_lot_indexes[end] != max_lot_indexes[end - 1]
            println(t)
        end

        curr_distribution = next_distribution
        # if curr_distribution[6] != 0
        #     println("hello 1")
        # end
        push!(all_distributions, curr_distribution)
        println("$(length(max_lots)): $(max_lots[end])")

    end

    max_lot_plot = bar(ones(length(max_lots)), color = map(i -> vcat(map(y -> collect(palette(:tab10)), 1:20)...)[i], max_lot_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)


    dist_plot = nothing
    dist_xs = collect(0:time_step_unit:num_time_steps*time_step_unit)
    dist_ys = []
    for i in 1:length(language_names)
        println(i)
        dist_ys = map(t -> all_distributions[t][i], 1:length(dist_xs))
        if isnothing(dist_plot)
            dist_plot = plot(dist_xs, dist_ys, label= (i < 11) ? replace(language_names_pretty[i], "_language.jl" => "") : "", legend=occursin("good", test_name) ? false : :right, color = vcat(map(y -> collect(palette(:tab10)), 1:20)...)[i], size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time", legendfontsize=5, titlefontsize=12)
        else
            dist_plot = plot(dist_plot, dist_xs, dist_ys, label= (i < 11) ? replace(language_names_pretty[i], "_language.jl" => "") : "", legend=occursin("good", test_name) ? false : :right, color = vcat(map(y -> collect(palette(:tab10)), 1:20)...)[i], size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time", legendfontsize=5, titlefontsize=12)
        end
    end

    max_lot_plot

    # dist_plot

    # plot(dist_plot, max_lot_plot, layout=(2, 1))

    accuracy_over_time_values = []
    for t in 1:length(max_lot_indexes)
        idx = max_lot_indexes[t]
        lang_name = language_names_pretty[idx]
        relate_defined = language_name_to_spec[lang_name]["relate"] == "RN"
        base_accuracy = accuracies[idx]
        mistake_prob = 0.0
        if relate_defined 
            mistake_prob = post_relate_mistake_prob_max - (t / num_time_steps) * (post_relate_mistake_prob_max - post_relate_mistake_prob_min)
        else
            mistake_prob = pre_relate_mistake_prob_max - (t / num_time_steps) * (pre_relate_mistake_prob_max - pre_relate_mistake_prob_min)
        end
        final_accuracy = base_accuracy * (1 - mistake_prob)
        push!(accuracy_over_time_values, final_accuracy)
    end

    accuracy_over_time_plot = plot(collect(0:length(max_lot_indexes) - 1), accuracy_over_time_values, xlims=(0,length(max_lot_indexes) - 1), ylims=(0.0, 1.0), title="MAP LoT Accuracy over Time", xlabel="Time", ylabel="Accuracy")


    average_accuracy_over_time_values = map(x -> 0.0, 1:length(dist_xs))
    for i in 1:length(language_names)
        println(i)
        lang_name = language_names_pretty[i]
        language_proportions = map(t -> all_distributions[t][i], 1:length(dist_xs))
        
        relate_defined = language_name_to_spec[lang_name]["relate"] == "RN"
        base_accuracy = accuracies[i]
        accuracies_over_time = []
        for t in 1:length(dist_xs)
            mistake_prob = 0.0
            if relate_defined 
                mistake_prob = post_relate_mistake_prob_max - (t / length(dist_xs)) * (post_relate_mistake_prob_max - post_relate_mistake_prob_min)
            else
                mistake_prob = pre_relate_mistake_prob_max - (t / length(dist_xs)) * (pre_relate_mistake_prob_max - pre_relate_mistake_prob_min)
            end
            final_accuracy = base_accuracy * (1 - mistake_prob)
            push!(accuracies_over_time, final_accuracy)
        end
        accuracy_proportions = language_proportions .* accuracies_over_time
        average_accuracy_over_time_values = average_accuracy_over_time_values .+ accuracy_proportions
    end

    average_accuracy_over_time_plot = plot(collect(0:length(dist_xs) - 1), average_accuracy_over_time_values, xlims=(0,length(dist_xs) - 1), ylims=(0.0, 1.0), title="Average LoT Accuracy over Time", xlabel="Time", ylabel="Accuracy", titlefontsize=12)

    if save_fig_title != ""
        p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, average_accuracy_over_time_plot, layout=(5, 1), size=(1000, 2500))
        save_fig_with_params(p, "$(test_name)_$(save_fig_title).png")
    end 

    (line_plot, max_utility_plot, dist_plot, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot)
end

plot_directory = "language/didactic/rational_number/plots"
function save_fig_with_params(p, title)
    num_plot_dirs = length(readdir(plot_directory))

    new_plot_dir = "$(plot_directory)/plot_$(num_plot_dirs)"
    mkdir(new_plot_dir)

    # save plot
    savefig(p, "$(new_plot_dir)/$(title)")

    # save plot params
    open(replace("$(new_plot_dir)/$(title)", ".png" => "_params.json"), "w+") do f 
        JSON.print(f, params_dict, 4)
    end
end

function size(x::Expr)
    s = 1
    for arg in x.args 
        s += size(arg)
    end
    s
end

function size(x::Symbol)
    1
end

function size(x::Union{Int, String, Bool, Nothing})
    1
end

function size(x::QuoteNode)
    size(x.value)
end

# line_plot, max_utility_plot, dist_plot, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test("bad_curriculum", "plot")
# line_plot, max_utility_plot, dist_plot, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test("bad_curriculum", "")

# p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, average_accuracy_over_time_plot, layout=(5, 1), size=(1000, 2500))
# save_fig_with_params(p, "$(test_name)_plot.png")

# plot(dist_plot, max_lot_plot, layout=(2, 1))