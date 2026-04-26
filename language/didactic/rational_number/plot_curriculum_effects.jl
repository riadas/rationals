model_file_name = "plot_stage1_v4.jl"
include(model_file_name)
curr_test_name = "good_curriculum"

physical_percentages = collect(0.0:0.01:1.0)

symbolic_physical_task_names = ["is_a_number_task", "arithmetic_task", "subtraction_task", "compare_task", "compare_task_bad"]
total_tasks = sum(map(t -> test_name_to_task_dict[curr_test_name][t][2], symbolic_physical_task_names))

curr_plots = []
full_knower_arrival_times = []
for percentage in physical_percentages 
    @show percentage
    num_physical_tasks = percentage * total_tasks 
    num_symbolic_tasks = total_tasks - num_physical_tasks 
    
    test_name_to_task_dict[curr_test_name]["is_a_number_task"] = (is_a_number_task, num_physical_tasks) 
    test_name_to_task_dict[curr_test_name]["arithmetic_task"] = (arithmetic_task, num_symbolic_tasks / 3)
    test_name_to_task_dict[curr_test_name]["subtraction_task"] = (subtraction_task, num_symbolic_tasks / 3)
    test_name_to_task_dict[curr_test_name]["compare_task"] = (compare_task, num_physical_tasks / 9 * 2)
    test_name_to_task_dict[curr_test_name]["compare_task_bad"] = (compare_task_bad, num_physical_tasks / 9)

    line_plot, maxs, max_utility_plot, dist_plot, max_lots, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test(curr_test_name, "", param_effects_memory_mod=0.0, param_effects_distance_mod=1.0, forget=true)

    final_stage_arrival_times = findall(x -> x == "abstract infinite divisibility language.jl", max_lots)
    if final_stage_arrival_times == []
        arrival_time = length(max_lots + 1)
    else
        arrival_time = minimum(final_stage_arrival_times)
    end

    plot(dist_plot, max_lot_plot, layout=(2, 1), size=(1000, 1000))
    # p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, average_accuracy_over_time_plot, layout=(5, 1), size=(1000, 2500))
    save_fig_with_params(p, "$(test_name)_plot_curr_effects_$(percentage).png")

    # plot(dist_plot, max_lot_plot, layout=(2, 1))

    push!(curr_plots, (deepcopy(dist_plot), deepcopy(max_lot_plot)))
    push!(full_knower_arrival_times, arrival_time)

    open("temp.txt", "w+") do f 
        write(f, join(full_knower_arrival_times, "\n"))
    end

end

i = findall(x -> x == minimum(full_knower_arrival_times), full_knower_arrival_times)[1]
println(physical_percentages[i])