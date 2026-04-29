include("plot_stage1_v4.jl")

curr_test_name = "good_curriculum"

line_plot, maxs, max_utility_plot, dist_plot, max_lots, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test(curr_test_name, "", param_effects_memory_mod=0.0, param_effects_distance_mod=1.0)

p = plot(dist_plot, max_lot_plot, layout=(2, 1), size=(1000, 1000))
p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, layout=(4, 1), size=(1000, 2000))
# save_fig_with_params(p, "$(test_name)_plot.png")

# savefig("$(plot_directory)/temp_$(curr_test_name).png")

plot(dist_plot, max_lot_plot, layout=(2, 1))

# MAP_correct_order = check_phase_order(max_lots, ["splitting", "ungrounded"], ["understanding", "infinite"], length(max_lots) + 1)

# final_arrival_time_utility = findall(x -> occursin("abstract infinite divisibility", x), maxs)[1]
# final_arrival_time_full_model = findall(x -> occursin("abstract infinite divisibility", x), max_lots)[1]

# println("Utility-Only full knower arrival time: $(final_arrival_time_utility)")
# println("Utility+Background full knower arrival time: $(final_arrival_time_full_model)")

# no intervention 
# Utility-Only full knower arrival time: 171
# Utility+Background full knower arrival time: 527

# is-a-number intervention 
# Utility-Only full knower arrival time: 171
# Utility+Background full knower arrival time: 514

# arithmetic intervention 
# Utility-Only full knower arrival time: 171
# Utility+Background full knower arrival time: 529