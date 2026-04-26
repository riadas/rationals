include("../../tasks.jl")

using Plots 
using Combinatorics
using JSON

language_names = map(x -> "L$(x)", collect(1:13))

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
    
    "11_space_number_infinite_divisibility_language.jl",
    "12_space_matter_infinite_divisibility_language.jl",
    "13_number_matter_infinite_divisibility_language.jl",

    "14_space_infinite_divisibility_no_arith_language.jl", 
    "15_abstract_infinite_divisibility_no_arith_language.jl",
    "16_number_infinite_divisibility_no_arith_language.jl",
    "17_matter_infinite_divisibility_no_arith_language.jl",

    "18_space_number_infinite_divisibility_no_arith_language.jl",
    "19_space_matter_infinite_divisibility_no_arith_language.jl",
    "20_number_matter_infinite_divisibility_no_arith_language.jl",
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

# NEW 4/25: LANGUAGE 11 
language11_definition_spec = deepcopy(language5_definition_spec)
language11_spec = deepcopy(language5_spec)

language11_definition_spec["infinite_divisibility_space"] = "infinite"
language11_spec["infinite_divisibility_space"] = true

language11_definition_spec["infinite_divisibility_number"] = "infinite"
language11_spec["infinite_divisibility_number"] = true

# NEW 4/25: LANGUAGE 12 
language12_definition_spec = deepcopy(language5_definition_spec)
language12_spec = deepcopy(language5_spec)

language12_definition_spec["infinite_divisibility_space"] = "infinite"
language12_spec["infinite_divisibility_space"] = true

language12_definition_spec["infinite_divisibility_weight"] = "infinite"
language12_spec["infinite_divisibility_weight"] = true

# NEW 4/25: LANGUAGE 12 
language13_definition_spec = deepcopy(language5_definition_spec)
language13_spec = deepcopy(language5_spec)

language13_definition_spec["infinite_divisibility_number"] = "infinite"
language13_spec["infinite_divisibility_number"] = true

language13_definition_spec["infinite_divisibility_weight"] = "infinite"
language13_spec["infinite_divisibility_weight"] = true

# NEW 4/26:

# space
language14_definition_spec = deepcopy(language4_definition_spec)
language14_spec = deepcopy(language4_spec)
language14_definition_spec["infinite_divisibility_space"] = "infinite"
language14_spec["infinite_divisibility_space"] = true

# space, number, matter
language15_definition_spec = deepcopy(base_language_definition_spec)
language15_spec = deepcopy(base_language_spec)

# number
language16_definition_spec = deepcopy(language4_definition_spec)
language16_spec = deepcopy(language4_spec)

language16_definition_spec["infinite_divisibility_number"] = "infinite"
language16_spec["infinite_divisibility_number"] = true

# matter
language17_definition_spec = deepcopy(language4_definition_spec)
language17_spec = deepcopy(language4_spec)

language17_definition_spec["infinite_divisibility_weight"] = "infinite"
language17_spec["infinite_divisibility_weight"] = true


## space, number
language18_definition_spec = deepcopy(language4_definition_spec)
language18_spec = deepcopy(language4_spec)

language18_definition_spec["infinite_divisibility_space"] = "infinite"
language18_spec["infinite_divisibility_space"] = true

language18_definition_spec["infinite_divisibility_number"] = "infinite"
language18_spec["infinite_divisibility_number"] = true

## space, matter
language19_definition_spec = deepcopy(language4_definition_spec)
language19_spec = deepcopy(language4_spec)

language19_definition_spec["infinite_divisibility_space"] = "infinite"
language19_spec["infinite_divisibility_space"] = true

language19_definition_spec["infinite_divisibility_weight"] = "infinite"
language19_spec["infinite_divisibility_weight"] = true

# number, matter
language20_definition_spec = deepcopy(language4_definition_spec)
language20_spec = deepcopy(language4_spec)

language20_definition_spec["infinite_divisibility_number"] = "infinite"
language20_spec["infinite_divisibility_number"] = true

language20_definition_spec["infinite_divisibility_weight"] = "infinite"
language20_spec["infinite_divisibility_weight"] = true

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

    "11_space_number_infinite_divisibility_language.jl"  => language11_definition_spec,
    "12_space_matter_infinite_divisibility_language.jl"  => language12_definition_spec,
    "13_number_matter_infinite_divisibility_language.jl"  => language13_definition_spec,

    "14_space_infinite_divisibility_no_arith_language.jl" => language14_definition_spec, 
    "15_abstract_infinite_divisibility_no_arith_language.jl"  => language15_definition_spec,
    "16_number_infinite_divisibility_no_arith_language.jl"  => language16_definition_spec,
    "17_matter_infinite_divisibility_no_arith_language.jl"  => language17_definition_spec,

    "18_space_number_infinite_divisibility_no_arith_language.jl"  => language18_definition_spec,
    "19_space_matter_infinite_divisibility_no_arith_language.jl"  => language19_definition_spec,
    "20_number_matter_infinite_divisibility_no_arith_language.jl"  => language20_definition_spec,
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

    "11_space_number_infinite_divisibility_language.jl"  => language11_spec,
    "12_space_matter_infinite_divisibility_language.jl"  => language12_spec,
    "13_number_matter_infinite_divisibility_language.jl"  => language13_spec,

    "14_space_infinite_divisibility_no_arith_language.jl" => language14_spec, 
    "15_abstract_infinite_divisibility_no_arith_language.jl"  => language15_spec,
    "16_number_infinite_divisibility_no_arith_language.jl"  => language16_spec,
    "17_matter_infinite_divisibility_no_arith_language.jl"  => language17_spec,

    "18_space_number_infinite_divisibility_no_arith_language.jl"  => language18_spec,
    "19_space_matter_infinite_divisibility_no_arith_language.jl"  => language19_spec,
    "20_number_matter_infinite_divisibility_no_arith_language.jl"  => language20_spec,
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