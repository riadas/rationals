include("plot_stage1_v4.jl")

curr_test_name = "bad_curriculum"

line_plot, maxs, max_utility_plot, dist_plot, max_lots, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test(curr_test_name, "", forget=false)

# p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, average_accuracy_over_time_plot, layout=(5, 1), size=(1000, 2500))
# save_fig_with_params(p, "$(test_name)_plot.png")

savefig("$(plot_directory)/temp_$(curr_test_name).png")

plot(dist_plot, max_lot_plot, layout=(2, 1))
