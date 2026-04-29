model_name = "plot_stage1_v4.jl"
curr_test_name = "good_curriculum"

interventions = [
    "", # no intervention (baseline)
    ("is_a_number_task", 3),
    ("arithmetic_task", 3),
]

UB_predictions = []
U_predictions = [] 

for intervention in interventions 
    include(model_name)

    line_plot, maxs, max_utility_plot, dist_plot, max_lots, max_lot_plot, accuracy_over_time_plot, average_accuracy_over_time_plot = run_test(curr_test_name, "", param_effects_memory_mod=0.0, param_effects_distance_mod=1.0, intervention=intervention)

    p = plot(dist_plot, max_lot_plot, layout=(2, 1), size=(1000, 1000))
    p = plot(line_plot, max_utility_plot, dist_plot, max_lot_plot, layout=(4, 1), size=(1000, 2000))
    # save_fig_with_params(p, "$(test_name)_plot.png")

    savefig("$(plot_directory)/temp_$(curr_test_name).png")

    # plot(dist_plot, max_lot_plot, layout=(2, 1))

    # MAP_correct_order = check_phase_order(max_lots, ["splitting", "ungrounded"], ["understanding", "infinite"], length(max_lots) + 1)

    final_arrival_time_utility = findall(x -> occursin("abstract infinite divisibility", x), maxs)[1]
    final_arrival_time_full_model = findall(x -> occursin("abstract infinite divisibility", x), max_lots)[1]

    println("Utility-Only full knower arrival time: $(final_arrival_time_utility)")
    println("Utility+Background full knower arrival time: $(final_arrival_time_full_model)")

    push!(UB_predictions, final_arrival_time_full_model)
    push!(U_predictions, final_arrival_time_utility)
end

labels = ["no intervention\n(baseline)", "symbolic-physical\nintervention\n(is-a-number)", "symbolic-only\nintervention\n(arithmetic)"]

# UB intervetion effects plot
relative_UB_predictions =  UB_predictions .- UB_predictions[1]
UB_plot = bar(labels, relative_UB_predictions, ylabel="Arrival Time Change (Time Step)", xlabel="Intervention", title="U+B Model (\"Causal Gateway\" Theory): Intervention Effects", ylims=(-20, 20), titlefontsize=18, xtickfontsize=15, ytickfontsize=15, bottom_margin=3cm, left_margin=2cm, legend=false, color=:gray, xguidefontsize=18, yguidefontsize=18)
UB_percentages = relative_UB_predictions ./ UB_predictions[1] * 100
annotate!(labels[1:1], relative_UB_predictions[1:1], map(i -> "$(relative_UB_predictions[i] >= 0 ? "+" : "")$(relative_UB_predictions[i]) ($(round(UB_percentages[i], digits=2))%)", 1:1), :bottom)
annotate!(labels[2:2], relative_UB_predictions[2:2], map(i -> "$(relative_UB_predictions[i] >= 0 ? "+" : "")$(relative_UB_predictions[i]) ($(round(UB_percentages[i], digits=2))%)", 2:2), :top)
annotate!(labels[3:3], relative_UB_predictions[3:3], map(i -> "$(relative_UB_predictions[i] >= 0 ? "+" : "")$(relative_UB_predictions[i]) ($(round(UB_percentages[i], digits=2))%)", 3:3), :bottom)

# U intervention effects plot
relative_U_predictions =  U_predictions .- U_predictions[1]
U_plot = bar(labels, relative_U_predictions, ylabel="Arrival Time Change (Time Step)", xlabel="Intervention", title="U Model (Non-\"Causal Gateway\" Theory): Intervention Effects", ylims=(-20, 20))
U_percentages = (relative_U_predictions) ./ U_predictions[1] * 100
annotate!(labels, relative_U_predictions, map(i -> "$(relative_U_predictions[i] >= 0 ? "+" : "")$(relative_U_predictions[i]) ($(round(U_percentages[i], digits=2))%)", 1:length(U_predictions)), :bottom, titlefontsize=18, xtickfontsize=15, ytickfontsize=15, bottom_margin=2cm, legend=false, color=:gray, xguidefontsize=18, yguidefontsize=18)

# comparison plot
plot(UB_plot, U_plot, layout=(1, 2), size=(2000, 1000))

# results:
# no intervention 
# Utility-Only full knower arrival time: 171
# Utility+Background full knower arrival time: 527

# is-a-number intervention 
# Utility-Only full knower arrival time: 171
# Utility+Background full knower arrival time: 514

# arithmetic intervention 
# Utility-Only full knower arrival time: 171
# Utility+Background full knower arrival time: 529