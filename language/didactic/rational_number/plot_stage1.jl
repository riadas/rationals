include("../../tasks.jl")

using Plots

correct_language_definition_spec = Dict([
    "halve1" => "RN(1, 2)",
    "halve2" => "RN(n, 2)",
    "halve3" => "RN(rn.numerator, rn.denominator * 2)",
    "double" => "RN(rn.numerator * 2, rn.denominator)",
    "divide1" => "RN(1, n)",
    "divide2" => "RN(rn.numerator, rn.denominator * n)",
    "multiply" => "RN(rn.numerator * n, rn.denominator)",
    "divide3" => "RN(m, n)", # "multiply(divide(NaturalNumber(1), m), n)",
    # "common_multiple" => "NaturalNumber(lcm(arg1.value, arg2.value))",
    # "scale" => "RN(rn.numerator * nn, rn.denominator * nn, false)",
    "compare_op" => 
        """
        cm = common_multiple(arg1.denominator, arg2.denominator)
        scaled_arg1 = scale(arg1, cm / arg1.denominator)
        scaled_arg2 = scale(arg2, cm / arg2.denominator)
        compare(arg1.numerator, arg2.numerator, operator)
        """,
    "add_op" => 
        """
        cm = common_multiple(arg1.denominator, arg2.denominator)
        scaled_arg1 = scale(arg1, cm / arg1.denominator)
        scaled_arg2 = scale(arg2, cm / arg2.denominator)
        RN(add(scaled_arg1.numerator, scaled_arg2.numerator), cm)
        """,
    "subtract_op" => 
        """
        cm = common_multiple(arg1.denominator, arg2.denominator)
        scaled_arg1 = scale(arg1, cm / arg1.denominator)
        scaled_arg2 = scale(arg2, cm / arg2.denominator)
        RN(subtract(scaled_arg1.numerator, scaled_arg2.numerator), cm)
        """,
    "multiply_op" => "RN(arg1.numerator * arg2.numerator, arg1.denominator * arg2.denominator)", # "divide(multiply(arg1, arg2.numerator), arg2.denominator)",
    "divide_op" => "RN(arg1.numerator * arg2.denominator, arg1.denominator * arg2.numerator)", # "divide(multiply(arg1, arg2.denominator), arg2.numerator)",
    "weight" => "obj.weight",
    "density" => "obj.weight / obj.volume",
    "infinite_divisibility_space" => "infinite",
    "infinite_divisibility_number" => "infinite",
    "infinite_divisibility_weight" => "infinite",
    "relate" => "true",
])

type_signatures_dict = Dict([
    "halve1" => [],
    "halve2" => [("n", NaturalNumber)],
    "halve3" => [("rn", RationalNumber)],
    "double" => [("rn", RationalNumber)],
    "divide1" => [("n", NaturalNumber)],
    "divide2" => [("rn", RationalNumber), ("n", NaturalNumber)],
    "multiply" => [("rn", RationalNumber), ("n", NaturalNumber)],
    "divide3" => [("n", NaturalNumber), ("m", NaturalNumber)],
    # "common_multiple" => "NaturalNumber(lcm(arg1.value, arg2.value))",
    # "scale" => [("rn", RationalNumber), ("nn", NaturalNumber)],
    "compare_op" => [("arg1", RationalNumber), ("arg2", RationalNumber)],
    "add_op" => [("arg1", RationalNumber), ("arg2", RationalNumber)],
    "subtract_op" => [("arg1", RationalNumber), ("arg2", RationalNumber)],
    "multiply_op" => [("arg1", RationalNumber), ("arg2", RationalNumber)],
    "divide_op" => [("arg1", RationalNumber), ("arg2", RationalNumber)],
    "weight" => [("obj", PhysicalObject)],
    "density" => [("obj", PhysicalObject)],
    "infinite_divisibility_space" => Coarseness,
    "infinite_divisibility_number" => Coarseness,
    "infinite_divisibility_weight" => Coarseness,
    "relate" => Bool,
])

base_context = Dict([
    "nn" => [],
    "rn" => [],
    "obj" => [],
    "op" => false,
])

function gen_nn(context, enum=false)
    possibilities = ["1", "2"]
    push!(possibilities, context["nn"]...)
    for rn in context["rn"]
        push!(possibilities, ["$(rn).numerator", "$(rn).denominator"]...)
    end

    if context["op"]
        prods = [Iterators.product(possibilities, ["+", "-", "*"], possibilities)...]
        push!(possibilities, map(p -> "$(p[1]) $(p[2]) $(p[3])", filter(x -> x[1] != x[3] && (x[2] == "-" || (length(x[1]) > length(x[3])) || (length(x[1]) == length(x[3])) && x[1] < x[3]), prods))...)
    end

    filter!(p -> count(x -> x == "1", split(p)) + count(x -> x == "2", split(p)) < 3, possibilities)

    enum ? possibilities : rand(possibilities)
end

function gen_rn(context, enum=false)
    possibilities = []
    nn_possibilities = gen_nn(context, true)

    prods = [Iterators.product(nn_possibilities, nn_possibilities)...]
    push!(possibilities, map(p -> "RN($(p[1]), $(p[2]))", filter(x -> x[1] != x[2] && !(occursin(".numerator", x[2]) || occursin(".denominator", x[1])), prods))...)

    arg_names = [context["nn"]..., context["rn"]...]
    # println(arg_names)
    # println(possibilities)
    filter!(p -> foldl(&, map(n -> occursin(n, p), arg_names), init=true), possibilities)
    filter!(p -> count(x -> x == true, map(x -> occursin(x, p),["+", "-", "*"])) <= 1, possibilities)
    
    arith_prods = [Iterators.product(["1", "2"], ["+", "-", "*"], ["1", "2"])...]
    arith_prod_strs = map(p -> "$(p[1]) $(p[2]) $(p[3])", arith_prods)
    filter!(p -> !foldl(|, map(x -> occursin(x, p) , arith_prod_strs), init=false), possibilities)

    enum ? possibilities : rand(possibilities)
end

function gen_obj_property(context, enum=false)
    possibilities = ["obj.weight", "obj.weight / obj.volume"]
    enum ? possibilities : rand(possibilities)
end

function gen_coarseness(context, enum=false)
    possibilities = ["coarse", "fine", "infinite"]
    enum ? possibilities : rand(possibilities)
end

function gen_bool(context, enum=false)
    possibilities = ["true", "false"]
    enum ? possibilities : rand(possibilities)
end

function gen_function_definition(type_signature, op=false, enum=false)
    context = deepcopy(base_context)
    context["op"] = op
    if type_signature isa AbstractArray 
        # println(type_signature)
        num_output = true
        for tup in type_signature 
            # println(tup)
            if tup[2] == NaturalNumber 
                # println("whoa")
                push!(context["nn"], tup[1])
            elseif tup[2] == RationalNumber 
                push!(context["rn"], tup[1])
            elseif tup[2] == PhysicalObject 
                push!(context["obj"], tup[1])
                num_output = false
            end
        end
        # println(context)
        if num_output 
            gen_rn(context, enum)
        else
            gen_obj_property(context, enum)
        end
    elseif type_signature == Coarseness
        gen_coarseness(context, enum)
    elseif type_signature == Bool 
        gen_bool(context, enum)
    end
end

function gen_language_specs()
    empty_language_definition_spec = Dict()
    for k in keys(empty_language_definition_spec)
        empty_language_definition_spec[k] = []
    end

    for k in keys(type_signatures_dict) 
        type_signature = type_signatures_dict[k]
        if type_signature isa AbstractArray && RationalNumber in map(t -> t[2], type_signature)
            op = true 
        else
            op = false
        end
        
        possible_definitions = gen_function_definition(type_signature, op, true)
        # println(length(possible_definitions))
        # println(possible_definitions)
        if type_signature isa AbstractArray && PhysicalObject in map(t -> t[2], type_signature)
            push!(possible_definitions, "undifferentiated_weight_density(obj)")
        elseif !(type_signature in [Coarseness, Bool])
            push!(possible_definitions, "NullNumber")
        end

        if !occursin("halve", k) && !occursin("double", k) && !(type_signature isa AbstractArray && (length(type_signature) == 0 || length(type_signature) == 1 && type_signature[end][end] == NaturalNumber))
            # println("hi 1")
            # println(length(possible_definitions))
            filter!(p -> !(occursin("1", replace(replace(p, "arg1" => ""), "arg2" => "")) || occursin("2", replace(replace(p, "arg1" => ""), "arg2" => ""))), possible_definitions)
            # println("hi 2")
            # println(possible_definitions)
            # println(length(possible_definitions))
        end

        pairs = [("add", "+"), ("subtract", "-"), ("multiply", "*"), ("divide", "*"), ("halve", "*"), ("double", "*")]
        all_ops = ["+", "-", "*"]
        for pair in pairs 
            if occursin(pair[1], k)
                remaining_ops = filter(x -> x != pair[2], all_ops)
                filter!(p -> !foldl(|, map(x -> occursin(x, p), remaining_ops), init=false), possible_definitions)
            end
        end
        filter!(p -> !occursin("* 1", p), possible_definitions)
        # println("hi 3")
        # println(length(possible_definitions))
        # println(possible_definitions)

        empty_language_definition_spec[k] = possible_definitions
    end
    empty_language_definition_spec["compare_op"] = ["NullNumber", "nn_intrusion_compare(arg1, arg2)"]
    empty_language_definition_spec
end

function count_languages(all_definitions_spec)
    counts = map(k -> length(all_definitions_spec[k]), [keys(all_definitions_spec)...])
    foldl(*, counts, init=1)
end

all_definitions_spec = gen_language_specs()
c = count_languages(all_definitions_spec)

selected_NN_intrusions_dict = Dict([
    "compare_op" => "nn_intrusion_compare",
    "add_op" => "RN(arg1.numerator + arg2.numerator, arg1.denominator + arg2.denominator)",
    "subtract_op" => "RN(arg1.numerator - arg2.numerator, arg1.denominator - arg2.denominator)",
])

selected_default_dict = Dict([
    "compare_op" => "NullNumber",
    "add_op" => "NullNumber",
    "subtract_op" => "NullNumber",
])

function generate_selected_languages(intrusions=["compare_op", "add_op", "subtract_op"])
    # original 8 specs, plus modifications to specs 5-8: for each, the 3^3 NN/UN versions
    base_specs_to_modify = []
end