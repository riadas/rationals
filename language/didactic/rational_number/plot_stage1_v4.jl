include("../../macro_compression/compiler_variant.jl")

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

function compute_compression_ratio(language; param_effects_memory_mod=0.0)
    lang_spec = language_name_to_spec[language]
    lang_spec["relate"] == "RN" ? (0.6 + param_effects_memory_mod) : 1.0
end

function compute_computation_costs(base_computation_costs)
    # normalization components
    all_task_vals = vcat(map(l -> map(t -> base_computation_costs[l][t], collect(keys(base_computation_costs[l]))), language_names_pretty)...)
    max_task_val = maximum(all_task_vals)
    min_task_val = minimum(all_task_vals)

    function normalize(x, max_task_val, min_task_val)
        (x - min_task_val) / (max_task_val - min_task_val)
    end

    average_language_costs = []
    for language_name in language_names_pretty 
        task_vals = map(t -> base_computation_costs[language_name][t], collect(keys(base_computation_costs[language_name])))
        # below: useful for plotting, but not strictly necessary
        normalized_task_vals = map(x -> normalize(x, max_task_val, min_task_val), task_vals)
        push!(average_language_costs, mean(normalized_task_vals))
    end
    
    average_language_costs = (average_language_costs .- minimum(average_language_costs)) ./ (maximum(average_language_costs) - minimum(average_language_costs))

    average_language_costs
end

function compute_computation_costs_corrected(base_computation_costs, normalized=true)
    # normalization components
    all_task_vals = vcat(map(l -> map(t -> base_computation_costs[l][t], collect(keys(base_computation_costs[l]))), language_names_pretty)...)
    max_task_val = maximum(all_task_vals)
    min_task_val = minimum(all_task_vals)

    function normalize(x, max_task_val, min_task_val)
        (x - min_task_val) / (max_task_val - min_task_val)
    end

    new_base_computation_costs = Dict()
    for language_name in language_names_pretty 
        for task_name in collect(keys(base_computation_costs[language_name])) 
            task_val = base_computation_costs[language_name][task_name]
            new_base_computation_costs[language_name][task_name] = normalize(task_val, max_task_val, min_task_val)
        end
    end

    average_language_costs = []
    for language_name in language_names_pretty 
        cost = compute_computation_cost_efficient(lang_name, task_dict, new_base_computation_costs, normalized)
        push!(average_language_costs, cost)
    end

    average_language_costs = (average_language_costs .- minimum(average_language_costs)) ./ (maximum(average_language_costs) - minimum(average_language_costs))
end

# UTILITY COMPONENT 1/2

function compute_representation_costs(; param_effects_memory_mod=0.0, compiler_based=false, infinite_scale=1.0)
    if compiler_based 
        compute_memory_costs_compressed(infinite_scale=infinite_scale, param_effects_memory_mod=param_effects_memory_mod)
    else
        costs = []
        for language in language_names_pretty 
            cost = compute_complexity_cost(language) * compute_compression_ratio(language, param_effects_memory_mod=param_effects_memory_mod)
            push!(costs, cost)
        end
        costs
    end
end

# UTILITY COMPONENT 2/2
function compute_task_accuracy_efficient(lang_name, task_dict, normalized=true)
    if lang_name in keys(base_accuracies)
        score = 0.0 
        total_tasks = sum(map(k -> task_dict[k][2], [keys(task_dict)...]))
        for task_name in keys(task_dict)
            num_tasks = task_dict[task_name][2]
            accuracy = base_accuracies[lang_name][task_name]
            score += accuracy * num_tasks
        end
        if normalized 
            score / total_tasks
        else
            score / (curr_test_name == "good_curriculum" ? 75.0 : 58.0)
        end
    else
        compute_score(lang_name, task_dict, "../..")
    end
end

function compute_computation_cost_efficient(lang_name, task_dict, base_computation_costs_, normalized=true)
    score = 0.0 
    total_tasks = sum(map(k -> task_dict[k][2], [keys(task_dict)...]))
    for task_name in keys(task_dict)
        num_tasks = task_dict[task_name][2]
        computation_cost = base_computation_costs_[lang_name][task_name]
        score += computation_cost * num_tasks
    end
    if normalized 
        score / total_tasks
    else
        score / curr_test_name == "good_curriculum" ? 75.0 : 58.0
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
function distance_between_specs(spec1, spec2, relate_factor, spec2_taught=1.0; param_effects_distance_mod=1.0)
    dist = 0
    spec2_lower_at_least_once = false
    
    # compute base edit distance (between specs)
    for k in keys(spec1)
        if spec1[k] != spec2[k] && !(k in ["weight", "density"])
            if spec1[k] == "RN" || spec2[k] == "RN"
                if occursin("_op", k)
                    dist += 2.0 # operation semantics are harder to learn because longer DL
                else
                    dist += 1.0
                end
            else # natural number intrusions are easier to learn
                dist += 0.5
            end

            if spec1[k] == "RN" && spec2[k] in ["NN", "UN"]
                spec2_lower_at_least_once = true # spec1 is lower at least once
            end
        end
    end

    if spec1["relate"] != "RN" && spec2["relate"] == "RN"
        if foldl(&, map(x -> spec1[x] == "RN", ["halve1", "halve2", "halve3", "double", "divide1", "divide2", "divide3", "multiply"]), init=true)
            dist += 20 - 19 * relate_factor
        else
            dist = dist * 10 * param_effects_distance_mod
        end
    end

    missing_structure_param = 10
    structure_param = 0.2

    # easier to grasp fraction operations after symbolic-physical analogy discovered
    if spec1["relate"] == "RN" && spec2["relate"] == "RN" && ((spec1["compare_op"] != "RN" && spec2["compare_op"] == "RN") || (spec1["add_op"] != "RN" && spec2["add_op"] == "RN") || (spec1["subtract_op"] != "RN" && spec2["subtract_op"] == "RN"))
        dist = dist / (1 + structure_param * 1.5)
    end

    # --- INFINITE DIVISIBILITY: CO-CONSTRUCTION ---
    # easier to grasp infinite divisibility of space after symbolic-physical analogy discovered
    if spec1["infinite_divisibility_space"] != "RN" && spec2["infinite_divisibility_space"] == "RN"
        if spec1["relate"] != "RN"
            dist += missing_structure_param
        else
            # hard to understand all the infinite divisibilities at once; space is the gateway
            if spec2["infinite_divisibility_number"] != "RN" && spec2["infinite_divisibility_weight"] != "RN"
                dist -= structure_param * 1.5 # space only
            else
                dist += missing_structure_param # space simultaneously with number, matter
            end
        end
    end

    # easier to grasp infinite divisibility of number, matter (invisible) after space (visible) 
    for pair in [("number", "weight"), ("weight", "number")]
        domain1, domain2 = pair
        if spec1["infinite_divisibility_$(domain1)"] != "RN" && spec2["infinite_divisibility_$(domain1)"] == "RN"
            if spec1["relate"] != "RN"
                dist += missing_structure_param
            end

            if spec1["infinite_divisibility_space"] != "RN"
                dist += missing_structure_param
            else
                if spec1["infinite_divisibility_$(domain2)"] == "RN" && spec2["infinite_divisibility_$(domain2)"] == "RN"
                    dist -= (1 - structure_param)
                end
            end
        end
    end    

    s = 0
    if dist != 0 
        if spec2_lower_at_least_once 
            s = 1 # no forgetting rule: spec1 would have to forget an RN definition to reach spec2
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
                # @show i
                function_names = ["compare_op", "add_op", "subtract_op"]
                forgetting_possibility_indices = []
                for i in 1:length(function_names)
                    if lang_spec[function_names[i]] == "RN"
                        push!(forgetting_possibility_indices, i)
                    end
                end
                possible_combos = filter(x -> x != [], [combinations(forgetting_possibility_indices)...])
                forgetting_prob = 0.125 * (pre_relate_mistake_prob_max - (t / (num_time_steps * time_step_unit)) * (pre_relate_mistake_prob_max - pre_relate_mistake_prob_min))
                # @show forgetting_prob
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

                new_distribution[i] = distribution[i] * (1 - (forgetting_prob / length(possible_combos)) * sum(rederiv_factors))
            end
        end
    end
    new_distribution = new_distribution ./ sum(new_distribution)
    # @show sum(new_distribution)
    new_distribution # TODO: use instruction_bias
end

function update_dist_based_on_forgetting_and_resynthesis(distribution, t, instruction_bias=0.0; forget=false)
    new_distribution = distribution
    if forget 
        new_distribution = forget_and_resynthesize_helper(distribution, t, instruction_bias, false) # FORGETTING AND RESYNTHESIS FINAL
    end
    
    new_distribution 
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

function plot_heatmap(relate_factor, title="", spec2_taught=1.0, backwards_bool=false; param_effects_distance_mod=1.0)
    transition_prob_identity = transition_prob_identity_base
    heatmap_values = []
    for i in 1:length(language_names)
        l1 = language_names_pretty[i] 
        push!(heatmap_values, [])
        for j in 1:length(language_names)
            l2 = language_names_pretty[j]
            l1_spec = language_name_to_spec[l1]
            l2_spec = language_name_to_spec[l2]
            dist, s = distance_between_specs(l1_spec, l2_spec, relate_factor, j < 21 ? spec2_taught : 0.0, param_effects_distance_mod=param_effects_distance_mod)
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

function compute_next_distribution(curr_distribution, t, spec2_taught=1.0, backwards_bool=false; param_effects_distance_mod=1.0)
    relate_factor = t * relate_task_proportion * relate_factor_coefficient
    relate_factor = relate_factor > 1 ? 1 : relate_factor
    push!(relate_factors, relate_factor)
    transition_probabilities, _ = plot_heatmap(relate_factor, "", spec2_taught, backwards_bool, param_effects_distance_mod=param_effects_distance_mod)
    next_distribution = map(x -> 0.0, 1:length(language_names))

    normalizer_jk_dict = Dict()
    for j in 1:length(language_names)
        normalizer = 0.0
        for k in 1:length(language_names)
            transition_prob_k = transition_probabilities[j][k]
            utility_k = utility_base^(compute_utility(k, t))
            normalizer += transition_prob_k * utility_k
        end
        normalizer_jk_dict[j] = normalizer
    end

    for i in 1:length(language_names)
        total = 0.0
        utility = utility_base^(compute_utility(i, t))
        for j in 1:length(language_names)
            transition_prob = transition_probabilities[j][i]
            normalizer = normalizer_jk_dict[j]
            total += curr_distribution[j] * (transition_prob * utility / normalizer)
        end
        next_distribution[i] = total
    end
    next_distribution = next_distribution ./ sum(next_distribution)
    next_distribution
end

# # BASE ACCURACY COMPUTATION
# good curriculum
good_task_dict = Dict([
    "halve_task" => (halve_task, 10.0),
    "double_task" => (double_task, 10.0),
    "split_task" => (split_task, 5.0),
    "combine_task" => (combine_task, 5.0),
    "divide_task" => (divide_task, 5.0),
    "is_a_number_task" => (is_a_number_task, 18.0), # 15 vs. 0 MODIFY
    "arithmetic_task" => (arithmetic_task, 6.0), # MODIFY
    "subtraction_task" => (subtraction_task, 6.0),
    "compare_task" => (compare_task, 4.0),
    "compare_task_bad" => (compare_task_bad, 2.0),
    "get_to_zero_space_task" => (get_to_zero_space_task, 2.0),
    "get_to_zero_rationals_task" => (get_to_zero_rationals_task, 1.0),
    "get_to_zero_weight_task" => (get_to_zero_weight_task, 1.0),
])

# bad curriculum
bad_task_dict = Dict([
    "halve_task" => (halve_task, 10.0),
    "double_task" => (double_task, 10.0),
    "split_task" => (split_task, 5.0),
    "combine_task" => (combine_task, 5.0),
    "divide_task" => (divide_task, 5.0),
    "is_a_number_task" => (is_a_number_task, 1.0), # 15 vs. 0 MODIFY
    "arithmetic_task" => (arithmetic_task, 6.0), # MODIFY
    "subtraction_task" => (subtraction_task, 6.0),
    "compare_task" => (compare_task, 4.0),
    "compare_task_bad" => (compare_task_bad, 2.0),
    "get_to_zero_space_task" => (get_to_zero_space_task, 2.0),
    "get_to_zero_rationals_task" => (get_to_zero_rationals_task, 1.0),
    "get_to_zero_weight_task" => (get_to_zero_weight_task, 1.0),
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

function compute_task_computation_cost_base(lang_name, task_dict)
    compute_computation_cost(lang_name, task_dict, "../..", eval_lang=false)
end

function compute_base_accuracies_and_computation_costs()
    saved_op_vals = Dict()
    for op_name in ["compare_op", "add_op", "subtract_op"]
        saved_op_vals[op_name] = Dict()
        for definition_val in ["UN", "NN", "RN"]
            saved_op_vals[op_name][definition_val] = -1
        end
    end

    options = ["UN", "NN", "RN"]
    option_combos = [Iterators.product(options, options, options)...]
    filter!(c -> !(c in [("UN", "UN", "UN"), ("RN", "RN", "RN")]), option_combos)


    corresponding_op_and_task = Dict([
        "arithmetic_task" => "add_op",
        "subtraction_task" => "subtract_op",
        "compare_task" => "compare_op",
        "compare_task_bad" => "compare_op",
    ])

    base_accuracies = Dict()
    base_computation_costs = Dict()
    for language_name in language_names_pretty 
        base_accuracies[language_name] = Dict()
        base_computation_costs[language_name] = Dict()
        for task_name in keys(good_task_dict)
            atom_task_dict = Dict()
            atom_task_dict[task_name] = (good_task_dict[task_name][1], 1)
            
            # compute accuracy of language on task
            accuracy = compute_task_accuracy_base(language_name, atom_task_dict)
            base_accuracies[language_name][task_name] = accuracy

            # compute computation cost of language on task
            ## for non-variant languages: compute from scratch
            if !occursin("VARIANT", language_name)
                computation_cost = compute_task_computation_cost_base(language_name, atom_task_dict)
                if task_name in keys(corresponding_op_and_task)
                    corresponding_op = corresponding_op_and_task[task_name]
                    # store computation costs of operation tasks, for use in variant setting
                    corresponding_lang_defn = language_name_to_spec[language_name][corresponding_op]
                    if saved_op_vals[corresponding_op][corresponding_lang_defn] == -1 
                        saved_op_vals[corresponding_op][corresponding_lang_defn] = computation_cost
                    end
                end
            ## for variant languages, use previously stored values when possible; otherwise compute from scratch
            else
                # if the task is not operation-based, then retrieve it from base (non-variant) language
                if !(task_name in keys(corresponding_op_and_task))
                    base_language_name = join(split(language_name, "_")[3:end], "_")
                    computation_cost = base_computation_costs[base_language_name][task_name]
                
                else # if the task is operation-based, check if it's been previously stored -- if not (i.e. NN option), compute and store it
                    variant_num = parse(Int, split(language_name, "_")[2])
                    combo = option_combos[variant_num]

                    defn = ""
                    if occursin("compare", task_name)
                        defn = combo[1]
                    elseif occursin("arithmetic", task_name)
                        defn = combo[2]
                    elseif occursin("subtract", task_name)
                        defn = combo[3]
                    else
                        error("task_name: $(task_name)")
                    end
                    @show defn

                    corresponding_op = corresponding_op_and_task[task_name]
                    if saved_op_vals[corresponding_op][defn] != -1
                        computation_cost = saved_op_vals[corresponding_op][defn]
                    else
                        computation_cost = compute_task_computation_cost_base(language_name, atom_task_dict)
                        saved_op_vals[corresponding_op][defn] = computation_cost
                    end

                end
            end
            base_computation_costs[language_name][task_name] = computation_cost

        end
    end
    (base_accuracies, base_computation_costs)
end

compute_base = (@isdefined compute_base) ? compute_base : true
if compute_base 
    base_accuracies, base_computation_costs = compute_base_accuracies_and_computation_costs()
end


function plot_utility_evolution(plot_colors)
    x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit)
    line_plot = nothing 
    yvals_dict = Dict()
    max_yvals = 0.0
    min_yvals = 0.0
    for i in 1:length(language_names[1:20])
        y_vals = map(x -> gamma_c*x*accuracies[i] - cost_c *(memory_costs[i] + 0.1 * (computational_costs[i] - 0.50)), x_vals)
        max_yvals = maximum([max_yvals, maximum(y_vals)])
        min_yvals = minimum([min_yvals, minimum(y_vals)])

        if isnothing(line_plot)
            line_plot = plot(x_vals, y_vals, size=(600, 450), xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:topleft, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = plot_colors[i], title="Utility vs. Cost Tolerance (Time)", xlabel="Cost Tolerance (Time)", ylabel="Utility")
        else
            line_plot = plot(line_plot, x_vals, y_vals, size=(600, 450),  xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:topleft, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = plot_colors[i], title="Utility vs. Cost Tolerance (Time)",  xlabel="Cost Tolerance (Time)", ylabel="Utility")
        end
        yvals_dict[i] = y_vals
    end

    max_indexes = []
    maxs = []
    for i in 1:length(x_vals) 
        vals = map(arr -> arr[i], map(n -> yvals_dict[n], 1:length(language_names[1:20])))
        # println(vals)
        index = findall(v -> v == maximum(vals), vals)[1]
        push!(max_indexes, index)
        push!(maxs, replace(join(split(language_names_pretty[index], "_")[2:end], " "), "language.jl" => ""))
        # println(maxs[end])
    end

    max_utility_plot = bar(ones(length(maxs)), color = map(i -> vcat(map(y -> plot_colors, 1:20)...)[i], max_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

    (max_indexes, maxs, max_utility_plot, line_plot)
end

# PARAMS
redefine_params = (@isdefined redefine_params) ? redefine_params : true
if redefine_params 
    # time step params
    time_step_unit = 0.01
    num_time_steps = 1000 # 6000 # 5500 # 3000

    # utility function params 
    gamma_c = 2.0
    cost_c = 0.1
    utility_base = 9.0 # 10000.0
    # gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)

    # transition probability params
    transition_prob_identity_base = 0.99
    transition_prob_identity_rate = 0.0003
    transition_prob_base = 2.0 # 100.0 2
    instruction_bias_base = 10.0

    # forgetting params (under forgetting model variant 1)
    pre_relate_mistake_prob_max = 0.4
    pre_relate_mistake_prob_min = 0.3
    post_relate_mistake_prob_max = 0.05
    post_relate_mistake_prob_min = 0.01

    # relate factor
    relate_factor_coefficient = 0.85 
    # relate_factor_coefficient = 0.4 * sqrt(utility_base / transition_prob_base)
end

# time step params
time_step_unit = 0.01
num_time_steps = 1000 # 6000 # 5500 # 3000

# utility function params 
gamma_c = 2.0
cost_c = 0.1
utility_base = 9.0 # 10000.0
# gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)

# transition probability params
transition_prob_identity_base = 0.99
transition_prob_identity_rate = 0.0003
transition_prob_base = 2.0 # 100.0 2
instruction_bias_base = 10.0

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

function run_test(test_name_, save_fig_title=""; param_effects_memory_mod=0.0, param_effects_distance_mod = 1.0, forget=false, intervention="")
    global test_name = test_name_
    params_dict["test_name"] = test_name

    task_dict = test_name_to_task_dict[test_name]
    params_dict["curriculum"] = Dict(map(k -> k => task_dict[k][2], collect(keys(task_dict))))

    global relate_task_proportion = task_dict["is_a_number_task"][2] / sum(map(k -> task_dict[k][2], [keys(task_dict)...]))

    normalized = intervention != "" ? false : true
    final_pre_knower_stage_reached = false

    # FINAL ACCURACIES
    global accuracies = []
    for language_name in language_names_pretty 
        push!(accuracies, compute_task_accuracy_efficient(language_name, task_dict, normalized))
    end
    # accuracies[1] = 0.0

    # FINAL COSTS
    # global memory_costs = compute_representation_costs(param_effects_memory_mod=param_effects_memory_mod)
    global memory_costs = compute_representation_costs(param_effects_memory_mod=param_effects_memory_mod, compiler_based=true, infinite_scale=50.0)
    memory_costs = memory_costs ./ (maximum(memory_costs) / 2)

    plot_colors = vcat(
        collect(palette(:tab10)), 
        palette(:tab20)[12], 
        palette(:tab20)[18], 
        palette(:tab20)[20],
        palette(:tab20b)[1:7]...,
    )

    # global computational_costs = map(x -> 0.5, 1:length(language_names))
    global computational_costs = compute_computation_costs(base_computation_costs)

    accuracy_plot = bar(map(x -> replace(join(split(x, "_")[2:end], " "), " language.jl" => ""), language_names_pretty[1:20]), accuracies[1:20], color = plot_colors, xrotation=305, size=(800, 525), legend=false, xlabel="LoT Stage", ylabel="Accuracy", title="Task Accuracy", ylims=(0.0, 1.0), xtickfontsize=6)

    memory_cost_plot = bar(map(x -> replace(join(split(x, "_")[2:end], " "), " language.jl" => ""), language_names_pretty[1:20]), memory_costs[1:20] ./ maximum(memory_costs[1:20]), color = plot_colors, xrotation=305, size=(800, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Memory Cost", ylims=(0.0, 1.0), xtickfontsize=6)

    computation_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty[1:20]), computational_costs[1:20], color = plot_colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Computation Cost", ylims=(0.0, 1.0))

    plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))

    # UTILITY PLOTS
    max_indexes, maxs, max_utility_plot, line_plot = plot_utility_evolution(plot_colors)

    # plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))
    # line_plot

    # MAP LoT PLOTS

    max_lot_indexes = [1]
    max_lots = [language_names_pretty[1]]
    curr_distribution = map(x -> 0.0, 1:length(language_names))
    curr_distribution[1] = 1.0
    push!(all_distributions, curr_distribution)
    for t in 0:time_step_unit:num_time_steps*time_step_unit
        next_distribution = compute_next_distribution(curr_distribution, t, 1.0, param_effects_distance_mod=param_effects_distance_mod)

        # forgetting/rederivation-based modification of new distribution
        next_distribution = update_dist_based_on_forgetting_and_resynthesis(next_distribution, t, forget=forget)
        if isnan(maximum(next_distribution))
            @show next_distribution
        end
        index = findall(v -> v == maximum(next_distribution), next_distribution)[1]
        push!(max_lot_indexes, index)
        push!(max_lots, join(split(language_names_pretty[index], "_")[2:end], " "))
        if max_lot_indexes[end] != max_lot_indexes[end - 1]
            println(t)
        end

        curr_distribution = next_distribution
        push!(all_distributions, curr_distribution)
        println("$(length(max_lots)): $(max_lots[end])")

        if intervention != "" && !final_pre_knower_stage_reached 
            # add additional tasks
            task_name, added_task_count = intervention
            task_dict[task_name] = (task_dict[task_name][1], task_dict[task_name][2] + added_task_count) 

            # recompute accuracies 
            global accuracies = []
            for language_name in language_names_pretty 
                push!(accuracies, compute_task_accuracy_efficient(language_name, task_dict, normalized))
            end

            # recompute utility evolution 
            max_indexes, maxs, max_utility_plot, line_plot = plot_utility_evolution(plot_colors)

            final_pre_knower_stage_reached = true
        end

    end

    max_lot_plot = bar(ones(length(max_lots)), color = map(i -> vcat(map(y -> plot_colors, 1:20)...)[i], max_lot_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)


    dist_plot = nothing
    dist_xs = collect(0:time_step_unit:num_time_steps*time_step_unit)
    dist_ys = []
    for i in 1:length(language_names)
        println(i)
        dist_ys = map(t -> all_distributions[t][i], 1:length(dist_xs))
        if isnothing(dist_plot)
            dist_plot = plot(dist_xs, dist_ys, label= (i < 21) ? replace(language_names_pretty[i], "_language.jl" => "") : "", legend=:right, color = vcat(map(y -> plot_colors, 1:20)...)[i], size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time", legendfontsize=5, titlefontsize=12, linewidth=2)
        else
            dist_plot = plot(dist_plot, dist_xs, dist_ys, label= (i < 21) ? replace(language_names_pretty[i], "_language.jl" => "") : "", legend=:right, color = vcat(map(y -> plot_colors, 1:20)...)[i], size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time", legendfontsize=5, titlefontsize=12, linewidth=2)
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

    (line_plot, maxs, max_utility_plot, dist_plot, max_lots, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot)
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

# line_plot, max_utility_plot, dist_plot, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test("bad_curriculum", "plot")
# line_plot, max_utility_plot, dist_plot, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test("bad_curriculum", "")

# p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, average_accuracy_over_time_plot, layout=(5, 1), size=(1000, 2500))
# save_fig_with_params(p, "$(test_name)_plot.png")

# plot(dist_plot, max_lot_plot, layout=(2, 1))

