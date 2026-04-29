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

1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
971
940
911
885
860
837
814
793
773
754
735
717
700
683
667
652
637
623
610
597
585
574
564
555
547
539
533
527
521
516
511
512
513
514
516
517
519
522
532
546
561
576
592
608
626
645
664
685
707
730
754
781
808
838
870
905
942
982
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003
1003