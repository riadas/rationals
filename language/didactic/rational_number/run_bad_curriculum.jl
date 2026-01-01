include("plot_stage1_v3.jl")

curr_test_name = "bad_curriculum"

line_plot, max_utility_plot, dist_plot, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test(curr_test_name, "")

# p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, average_accuracy_over_time_plot, layout=(5, 1), size=(1000, 2500))
# save_fig_with_params(p, "$(test_name)_plot.png")

plot(dist_plot, max_lot_plot, layout=(2, 1))

savefig("$(plot_directory)/temp_$(curr_test_name).png")