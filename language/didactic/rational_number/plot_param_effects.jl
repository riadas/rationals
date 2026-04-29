model_file_name = "plot_stage1_v4.jl"
include(model_file_name)
curr_test_name = "good_curriculum"

function check_phase_order(phase_list, first_phase_prefixes, second_phase_prefixes, missing_index)
    indices = []
    for prefixes in [first_phase_prefixes, second_phase_prefixes]
        phase_indices = findall(x -> foldl(|, map(y -> occursin(y, x), prefixes), init=false), phase_list)
        phase_index = phase_indices == [] ? missing_index : phase_indices[1]
        push!(indices, phase_index)
    end

    @show indices
    indices[1] < indices[2] ? 1.0 : 0.0
end

distance_modifiers = [1.0]
for i in 1:9
    m = (distance_modifiers[end] + 0.124) / 2
    push!(distance_modifiers, m) 
end

arrs = []
results = []
# distance_modifiers = map(x -> (0.8)^x, collect(0:10))
# distance_modifiers = [1.0] # [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.01]
for distance_modifier_index in 1:length(distance_modifiers)
    @show distance_modifier_index 
    distance_modifier = distance_modifiers[distance_modifier_index]
    @show distance_modifier 
    
    utility_results = []
    MAP_results = []

    modifiers = collect(-1.0:0.1:3.0) # collect(-0.59:0.01:0.59) # collect(-1.18:0.02:1.18)
    for modifier_index in 1:length(modifiers)
        @show modifier_index 
        modifier = modifiers[modifier_index]

        (line_plot, 
        maxs, 
        max_utility_plot, 
        dist_plot, 
        max_lots, 
        max_lot_plot, 
        accuracy_over_time_plot, 
        average_accuracy_over_time_plot) = run_test(curr_test_name, "", param_effects_memory_mod = modifier, param_effects_distance_mod = distance_modifier)

        # utility order check
        utility_correct_order = check_phase_order(maxs, ["splitting", "ungrounded"], ["understanding", "infinite"], length(max_lots) + 1)
        MAP_correct_order = check_phase_order(max_lots, ["splitting", "ungrounded"], ["understanding", "infinite"], length(max_lots) + 1)

        push!(utility_results, utility_correct_order)
        push!(MAP_results, MAP_correct_order)
    end

    utility_valid_plot = bar(ones(length(modifiers)), color = map(i -> [:red, :green][Int(i) + 1], utility_results), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match, bar_width=1)
    MAP_valid_plot = bar(ones(length(modifiers)), color = map(i -> [:red, :green][Int(i) + 1], MAP_results), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match, bar_width=1)

    push!(arrs, (distance_modifier, utility_results, MAP_results))
    push!(results, (distance_modifier, utility_valid_plot, MAP_valid_plot))

    # plot(utility_valid_plot, MAP_valid_plot, layout=(2,1), size=(1000, 200))
    utility_plot = results[1][2]
    plots = [utility_plot, map(r -> r[end], results)...]

    # plot(plots..., layout=(length(plots), 1), size=(1000, 120 * length(plots)), xlabel="", bar_width=1)

    plot(map(p -> bar(p, bar_width=1, linecolor=:match), plots)..., layout=(length(plots), 1), size=(500, 50 * length(plots)), xlabel="", xticks=false, yticks=false)
end

utility_plot = results[1][2]
plots = [utility_plot, map(r -> r[end], results)...]

plot(plots..., layout=(length(plots), 1), size=(1000, 120 * length(plots)), xlabel="", bar_width=1)

plot(map(p -> bar(p, bar_width=1, linecolor=:match), plots)..., layout=(length(plots), 1), size=(500, 50 * length(plots)), xlabel="", xticks=false, yticks=false)