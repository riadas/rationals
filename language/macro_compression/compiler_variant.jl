include("utils.jl")
# include("../didactic/rational_number/generate_languages.jl")

abstract type Rule end
abstract type Element end

struct Type <: Element 
    symbol::Symbol
end

struct Func <: Element 
    name::Symbol
    type::Type
end

struct Relate <: Rule 
    e1::Element
    e2::Element
    cond::String
end

Relate(e1, e2) = Relate(e1, e2, "")

struct Generalize <: Rule 
    e1::Element 
    e2::Element
end

Base.string(t::Type) = string(t.symbol)
Base.string(f::Func) = "($(string(f.name)), $(string(f.type)))"
Base.string(r::Relate) = "@relate $(string(r.e1)) $(string(r.e2))"
Base.string(r::Generalize) = "@generalize $(string(r.e1)) $(string(r.e2))"

cq = Type(:CQ)
dq = Type(:DQ)

rn = Type(:RN)
nn = Type(:NN)
types = [cq, dq, rn, nn]

type_full_names_dict = Dict([
    "CQ" => "ContinuousQuantity",
    "DQ" => "DiscreteQuantity",
    "RN" => "RationalNumber",
    "NN" => "NaturalNumber",
])

pre_knower_rules = [
    Generalize(rn, nn),
    Relate(rn, Type(:Divide)),
    Relate(rn, Type(:Subtract), "(arg1 < arg2)"),
    
    Generalize(Func(:RN_op, rn), Func(:NN_op, nn))
]

post_knower_rules = [
    Relate(cq, rn),
    Generalize(nn, rn),
    Relate(rn, Type(:Divide)),

    Relate(Func(:halve_obj, cq), Func(:halve, rn)),
    Relate(Func(:double_obj, cq), Func(:double, rn)),

    Relate(Func(:split_obj, cq), Func(:divide_n, rn)),
    Relate(Func(:combine_obj, cq), Func(:multiply_m, rn)),
    Relate(Func(:divide_obj, cq), Func(:divide_n_m, rn)),
    
    Generalize(Func(:NN_op, nn), Func(:RN_op, rn))
]

default_rules = [
    Relate(nn, dq)
]

function format_whitespace(lang_str)
    # lines = split(lang_str, "\n\n\n")
    # filter!(x -> x != "", lines)
    # lang_str = join(lines, "\n")
    # lang_str = replace(lang_str, "\n@relate" => "@relate")
    # lang_str = replace(lang_str, "\n@f" => "@f")
    # lang_str = replace(lang_str, "\nend" => "\nend\n")
    lang_str = strip(lang_str)
    lang_str = replace(lang_str, "\n\n@relate (" => "\n@relate (")

    lang_str = replace(lang_str, " \n" => "\n")
    for n in 3:10
        whitespace = join(map(x -> "\n", 1:n))
        new_whitespace = join(map(x -> "\n", 1:(n - 1)))
        lang_str = replace(lang_str, whitespace => new_whitespace)
    end

    lang_str
end

function compress(lang_str, rules)
    lang_str_ = primary_compression(lang_str, rules)

    lang_str_ = secondary_compression(lang_str_, rules)
end

function primary_compression(lang_str, rules, helpers_derivable = false)
    lines = split(lang_str, "\n")
    
    # remove previously known elements
    ## remove abstract type statements -- can be derived later 
    lines = filter(x -> !occursin("abstract type", x), lines)
    lang_str = join(lines, "\n")

    ## remove NN struct and DQ struct
    for s in ["NN", "DQ"]
        struct_init_lines = findall(x -> occursin("struct $(s)", x), lines)[1]
        if struct_init_lines != []
            start_index = struct_init_lines[1]
            end_index = start_index + 2

            new_lines = [lines[1:start_index - 1]..., lines[end_index+1:end]...]
            lines = new_lines 
            lang_str = join(new_lines, "\n")
        end
    end

    ## remove default rules
    for rule in default_rules 
        lang_str = replace(lang_str, string(rule) => "")
    end
    lines = split(lang_str, "\n")

    # replace associated LoT syntax for each rule with the rule's rDSL syntax
    ## special handling for operation casts: Divide and Subtract
    if occursin("Divide", lang_str)
        divide_lines = filter(x -> occursin("Divide", x), lines)
        for i in 1:length(divide_lines)
            if i == 1 
                lang_str = replace(lang_str, divide_lines[i] => "@relate RN Divide")
                lines = split(lang_str, "\n")
            else
                filter!(x -> x != divide_lines[i], lines)
            end
        end
        lang_str = join(lines, "\n")
    end

    if occursin("::Subtract", lang_str) || occursin("Subtract(x::", lang_str)
        divide_lines = filter(x -> occursin("::Subtract", x) || occursin("Subtract(x::", x), lines)
        for i in 1:length(divide_lines)
            if i == 1 
                lang_str = replace(lang_str, divide_lines[i] => "@relate RN Subtract (arg1 < arg2)")
                lines = split(lang_str, "\n")
            else
                filter!(x -> x != divide_lines[i], lines)
            end
        end
        lang_str = join(lines, "\n")
    end

    remaining_rules = filter(r -> r.e1 isa Func || r.e1 isa Type && intersect([r.e1.symbol, r.e2.symbol], [:Divide, :Subtract]) == [], rules)

    new_rule_syntax_lines = []
    for rule in remaining_rules
        if rule isa Relate 
            if rule.e1 isa Type 
                push!(new_rule_syntax_lines, string(rule))
            else # func rule
                physical_elt = rule.e1
                physical_elt_name = string(physical_elt.name) 
                
                physical_function_init_lines = findall(x -> occursin("function $(physical_elt_name)(", x), lines)
                if physical_function_init_lines != []
                    start_index = physical_function_init_lines[1]
                    end_index = start_index + 2 

                    func_defn_lines = lines[start_index:end_index]
                    lang_str = replace(lang_str, join(func_defn_lines, "\n") => string(rule))
                end
            end
        else # Generalize rules
            if rule.e1 isa Type 
                push!(new_rule_syntax_lines, string(rule))
            else # func rule
                general_func = rule.e2 
                general_func_name = string(general_func.name)
                @show general_func_name

                if general_func_name == "RN_op"
                    general_func_names = ["RN_add", "RN_subtract", "RN_compare"]
                else
                    general_func_names = [general_func_name]
                end
                for i in 1:length(general_func_names)
                    general_func_name = general_func_names[i]
                    general_function_init_lines = findall(x -> occursin("function $(general_func_name)(", x), lines)
                    if general_function_init_lines != []
                        start_index = general_function_init_lines[1]
                        end_index = -1
                        nested = 0
                        for k in start_index:length(lines)
                            l = lines[k + 1]
                            if occursin("for", l) || occursin("if", l) || occursin("function", l)
                                nested += 1
                            elseif occursin("end", l)
                                if nested == 0 
                                    end_index = k + 1
                                    break     
                                else
                                    nested -= 1
                                end
                            end
                        end

                        if end_index == -1 
                            error("could not find end of function")
                        end

                        func_defn_lines = lines[start_index:end_index]
                        func_defn = join(func_defn_lines, "\n")
                        keep = false
                        if general_func_name == "RN_add" && (occursin(selected_NN_intrusions_dict["add_op"], func_defn) || occursin("NullNumber", func_defn))
                            keep = true                            
                        elseif general_func_name == "RN_subtract" && (occursin(selected_NN_intrusions_dict["subtract_op"], func_defn) || occursin("NullNumber", func_defn))
                            keep = true
                        elseif general_func_name == "RN_compare" && (occursin(selected_NN_intrusions_dict["compare_op"], func_defn) || occursin("NullNumber", func_defn))
                            keep = true
                        end

                        if i == 1 
                            if keep 
                                lang_str = replace(lang_str, func_defn => "$(string(rule))\n\n$(func_defn)")
                            else
                                lang_str = replace(lang_str, func_defn => string(rule))
                            end
                        elseif !keep
                            lang_str = replace(lang_str, func_defn => "")
                        end

                        if helpers_derivable 
                            lang_str = replace(lang_str, helper_template => "")
                        end

                    else
                        push!(new_rule_syntax_lines, string(rule))
                    end
                end
            end
        end
    end

    @show new_rule_syntax_lines
    new_rule_syntax = join(new_rule_syntax_lines, "\n")
    lang_str = "$(new_rule_syntax)\n$(lang_str)"

    if occursin("CQ", lang_str)
        # remove CQ struct
        lang_str = replace(lang_str, CQ_struct => "")
    end

    format_whitespace(lang_str)
end

function secondary_compression(lang_str, rules)
    lines = split(lang_str, "\n")
    custom_macros = []

    # meta-relational compression 
    func_type_pairs_frequency = Dict()
    for rule in rules 
        if rule isa Relate && rule.e1 isa Func 
            t1, t2 = (rule.e1.type, rule.e2.type)
            k = (t1, t2)
            if k in keys(func_type_pairs_frequency)
                push!(func_type_pairs_frequency[k], rule)
            else
                func_type_pairs_frequency[k] = [rule]
            end
        end
    end 

    for k in keys(func_type_pairs_frequency)
        similar_rules = func_type_pairs_frequency[k]
        if length(similar_rules) > 1 
            # construct custom macro 
            macro_name = "f"
            prev_macros = length(custom_macros)
            if prev_macros != 0
                macro_name = "$(macro_name)$(length)"
            end

            t1, t2 = k 
            abstracted_relate = Relate(Func(:arg1, t1), Func(:arg2, t2))
            custom_macro_definition = "@macro_expand $(macro_name) arg1 arg2 = $(string(abstracted_relate))"

            custom_macro_calls = []
            for r in similar_rules 
                call_ = "@$(macro_name) $(string(r.e1.name)) $(r.e2.name)"
                push!(custom_macro_calls, call_)
                lang_str = replace(lang_str, string(r) => call_)
            end
            lang_str = replace(lang_str, string(custom_macro_calls[1]) => "$(custom_macro_definition)\n$(string(custom_macro_calls[1]))")
        end
    end

    # compressed based on functional rules making type rules redundant
    type_rules = filter(r -> r.e1 isa Type, rules)
    func_rules = filter(r -> r.e1 isa Func, rules)

    redundant_rules = []
    for type_rule in type_rules 
        rule_version = type_rule isa Relate ? Relate : Generalize
        matching_func_rules = filter(r -> r isa rule_version && r.e1.type == type_rule.e1 && r.e2.type == type_rule.e2, func_rules)
        if length(matching_func_rules) != 0 
            push!(redundant_rules, type_rule)
        end
    end

    for rule in redundant_rules 
        # println(string(rule))
        lang_str = replace(lang_str, string(rule) => "")
    end

    # compressed based on translation function redundancies
    generalize_type_rules = filter(r -> r isa Generalize && r.e1 isa Type, rules)

    for rule in generalize_type_rules
        t1, t2 = (rule.e1.symbol, rule.e2.symbol) 
        # find translation function
        translation_lines = filter(x -> occursin("$(t2)(x::$(t1)) = ", x), lines)

        # find opposite translation function
        opp_translation_lines = filter(x -> occursin("$(t1)(x::$(t2)) = ", x), lines)
        if opp_translation_lines != [] && occursin("?", opp_translation_lines[1])
            lang_str = replace(lang_str, opp_translation_lines[1] => "")
        elseif translation_lines != [] && occursin("?", translation_lines[1])
            lang_str = replace(lang_str, translation_lines[1] => "")
        end

        # if the translation function is consistent, can derive the translation rule from it
        if translation_lines != [] && !occursin("?", translation_lines[1])
            lang_str = replace(lang_str, string(rule) => "")
        end
    end

    if occursin("RN", replace(lang_str, "Hidden(RN" => ""))
        # remove RN struct 
        lang_str = replace(lang_str, RN_struct => "")
    end

    lang_str = replace(lang_str, "\n\n\n" => "\n\n")

    format_whitespace(lang_str)
end

function expand(lang_str)
    old_lang_str = deepcopy(lang_str)

    lines = split(lang_str, "\n")
    relate_lines = filter(x -> occursin("@relate", x) && !occursin(" = ", x), lines)
    generalize_lines = filter(x -> occursin("@generalize", x), lines)

    relate_type_lines = filter(x -> !occursin("(", x) || occursin("(arg1 <", x), relate_lines)
    relate_function_lines = filter(x -> occursin("(", x) && !occursin("(arg1 <", x), relate_lines)

    generalize_type_lines = filter(x -> !occursin("(", x), generalize_lines)
    generalize_function_lines = filter(x -> occursin("(", x), generalize_lines)

    # handle operation casts: Divide, Subtract
    divide_lines = filter(l -> occursin("Divide", l), relate_type_lines)
    subtract_lines = filter(l -> occursin("Subtract", l), relate_type_lines)
    
    if divide_lines != []
        lang_str = replace(lang_str, divide_lines[1] => Divide_cast)
        relate_type_lines = filter(x -> !(x in divide_lines), relate_type_lines)
        lines = split(lang_str, "\n")
    end

    if subtract_lines != []
        lang_str = replace(lang_str, subtract_lines[1] => Subtract_cast)
        relate_type_lines = filter(x -> !(x in subtract_lines), relate_type_lines)
        lines = split(lang_str, "\n")
    end

    # handle custom macro 
    custom_macro_defn_lines = filter(x -> occursin("@macro_expand", x), lines)
    for macro_defn_line in custom_macro_defn_lines 
        macro_name = split(macro_defn_line, " ")[2]
        macro_arg_names_str = split(split(macro_defn_line, " = ")[1], " $(macro_name) ")[end]
        macro_arg_names = split(macro_arg_names_str, " ")
        macro_defn = split(macro_defn_line, " = ")[end]

        macro_calls = filter(x -> occursin("@$(macro_name)", x), lines)
        for macro_call in macro_calls
            args = split(macro_call, " ")[2:end] 
            new_line = macro_defn
            for i in 1:length(macro_arg_names)
                arg_name = macro_arg_names[i]
                arg_value = args[i] 
                new_line = replace(new_line, arg_name => arg_value)
            end            
            lang_str = replace(lang_str, macro_call => new_line)
            push!(relate_function_lines, new_line)
        end
        lang_str = replace(lang_str, macro_defn_line => "")
        lines = split(lang_str, "\n")
    end

    # construct second half of translation functions
    generalized_type_tuples = []
    
    for l in generalize_type_lines 
        specialized_type = split(l, " ")[2]
        generalized_type = split(l, " ")[3]
        push!(generalized_type_tuples, (specialized_type, generalized_type))
    end
    
    for l in generalize_function_lines 
        specialized_type = split(split(l, ", ")[2], ")")[1]
        generalized_type = split(split(l, ", ")[end], ")")[1]
        push!(generalized_type_tuples, (specialized_type, generalized_type))
    end

    unique!(generalized_type_tuples)

    for tup in generalized_type_tuples 
        s_type, g_type = tup 

        translation_func_lines = filter(x -> occursin("$(g_type)(x::$(s_type)", x), lines)

        if translation_func_lines == [] || occursin("?", translation_func_lines[1])
            # inconsistent type casting situation
            error_form = "NullNumber"
        else
            # consistent type casting situation
            error_form = "error(\"invalid cast\")"
        end

        opp_translation_func_lines = filter(x -> occursin("$(s_type)(x::$(g_type)", x), lines)
        if opp_translation_func_lines == []
            opp_translation_func = "$(s_type)(x::$(g_type)) = x.num == NN(1) ? x.num : $(error_form)"

            new_translation_lines = "$(translation_func_lines[1])\n$(opp_translation_func)"
            lang_str = replace(lang_str, translation_func_lines[1] => new_translation_lines)
            lines = split(lang_str, "\n")
        else
            translation_func = "$(g_type)(x::$(s_type)) = x.num == NN(1) ? x.num : $(error_form)"

            new_translation_lines = "$(opp_translation_func_lines[1])\n$(translation_func)"
            lang_str = replace(lang_str, opp_translation_func_lines[1] => new_translation_lines)
            lines = split(lang_str, "\n")
        end
    end

    # construct definitions of related functions 
    for line in relate_function_lines 
        r = ["@relate ", "(", ")", ","]
        new_line = line
        for x in r 
            new_line = replace(new_line, x => "")
        end
        func1_name, func1_type, func2_name, func2_type = split(new_line, " ")
        extra_args = split(filter(x -> occursin("function $(func2_name)(", x), lines)[1], "), ")[end]

        new_func_defn = "$(relate_func_template)\n"
        new_func_defn = replace(new_func_defn, "[func1_name]" => func1_name)
        new_func_defn = replace(new_func_defn, "[func1_type]" => func1_type)
        new_func_defn = replace(new_func_defn, "[func2_name]" => func2_name)
        new_func_defn = replace(new_func_defn, "[func2_type]" => func2_type)
        new_func_defn = replace(new_func_defn, "[extra_args]" => extra_args)

        lang_str = replace(lang_str, line => new_func_defn)
    end
    lines = split(lang_str, "\n")

    # construct appropriate structs based on related / generalized types 
    if occursin("RN", replace(old_lang_str, "Hidden(RN" => ""))
        lang_str = "$(RN_struct)\n\n$(lang_str)"
    end

    if occursin("CQ", old_lang_str)
        lang_str = replace(lang_str, RN_struct => "$(RN_struct)\n\n$(CQ_struct)\n")
    end

    # construct definition of generalized func
    # TODO: update this to handle variants 
    if occursin("RN_op", old_lang_str)
        num_intrusions = count(x -> occursin(selected_NN_intrusions_dict[x], lang_str), ["add_op", "subtract_op", "compare_op"])
        if num_intrusions < 3
            RN_op_str = ""
            symbol_dict = Dict(["add_op" => ":+", "subtract_op" => ":-", "compare_op" => "op"])
            for func_name in ["add_op", "subtract_op", "compare_op"]
                formatted_name = "RN_$(split(func_name, "_")[1])"
                if !occursin(formatted_name, lang_str)                     
                    func_defn = "function $(formatted_name)(x::RN, y::RN$(func_name == "compare_op" ? ", op::Symbol" : ""))\n    $(replace(final_defn, "(op)" => "($(symbol_dict[func_name]))"))end"
                    RN_op_str = "$(RN_op_str)\n$(func_defn)\n"
                end
            end
            lang_str = "$(lang_str)\n\n$(RN_op_str)"
        end
    end

    # add back default / known items
    lang_str = "$(prior_knowledge)\n$(lang_str)"

    # construct abstract type definitions 
    if ("NN", "RN") in generalized_type_tuples 
        additional_defns = """abstract type RationalNumber <: NumberSymbol end 
        abstract type NaturalNumber <: RationalNumber end
        abstract type ContinuousQuantity <: PhysicalQuantity end
        abstract type DiscreteQuantity <: ContinuousQuantity end
        """
    elseif ("RN", "NN") in generalized_type_tuples 
        additional_defns = """abstract type NaturalNumber <: NumberSymbol end 
        abstract type RationalNumber <: NaturalNumber end
        abstract type DiscreteQuantity <: PhysicalQuantity end
        """
    else 
        additional_defns = """abstract type NaturalNumber <: NumberSymbol end 
        abstract type DiscreteQuantity <: PhysicalQuantity end
        """
    end
    lang_str = "abstract type NumberSymbol end\nabstract type PhysicalQuantity end\n$(additional_defns)\n$(lang_str)"

    for line in vcat(relate_lines, generalize_lines)
        lang_str = replace(lang_str, line => "")
    end

    format_whitespace(lang_str)
end

relate_func_template = """function [func1_name](x::[func1_type]=[func1_type](1, 1), [extra_args]
    [func1_type]([func2_name](x.size))
end"""

RN_struct = """struct RN <: RationalNumber
    num::NN
    denom::NN
end"""

CQ_struct = """struct CQ <: ContinuousQuantity
    size::RN
end
"""

prior_knowledge = """ 
struct NN <: NaturalNumber 
    value::Int 
end

struct DQ <: DiscreteQuantity 
    size::NN
end
"""

RN_op_defn = """function RN_op(x::RN, y::RN, op::Symbol)
   cm = common_multiple(arg1.denominator, arg2.denominator)
   scaled_arg1 = scale(arg1, cm / arg1.denominator)
   scaled_arg2 = scale(arg2, cm / arg2.denominator)
   RN(eval(op)(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end
"""

add_RN_template = """function add_RN(x::RN, y::RN)
    [defn]
end
"""

subtract_RN_template = """function subtract_RN(x::RN, y::RN)
    [defn]
end
"""

compare_RN_template = """function compare_RN(x::RN, y::RN)
    [defn]
end
"""

abstract_type_defns = """
abstract type NumberSymbol end
abstract type PhysicalQuantity end
"""

Divide_cast = """RN(x::Divide) = RN(x.arg1, x.arg2)
Divide(x::RN) = Divide(x.num, x.denom)
"""

Subtract_cast = """RN(x::Subtract) = x.arg1 < x.arg2 ? RN(x.arg1, x.arg2) : NullNumber
Subtract(x::RN) = x.num < x.denom ? Subtract(x.num, x.denom) : NullNumber 
"""

# TODO: translation between spec and compressed/expanded syntax
# TODO: handling the NN intrusion cases
# TODO: figure out final handling of @invariant scale

compressed_lang_template = """ 
function halve_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Subtract(n, n - 1)))
end

function double_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Add(1, m - 1)))
end
"""

halve_symbolic_template = """
function halve(x::RN=RN(1, 1))::RN 
    divide_n(x, 2)
end

function double(x::RN=RN(1, 1))::RN 
    multiply_m(x, m)
end
"""

split_combine_divide_template = """
function divide_n(x::RN=RN(1, 1), n::NN)::RN
   RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)::RN
   RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)::RN
   multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end

function split_obj(x::PQ=PQ(Hidden(RN(1, 1))), n::NN)::PQ
   build(DQ(x, Subtract(n, n - 1))) 
end

function combine_obj(x::PQ=PQ(Hidden(RN(1, 1))), m::NN)::PQ
   build(DQ(x, Add(1, m - 1))) 
end

function divide_obj(x::PQ=PQ(Hidden(RN(1, 1))), n::NN)::PQ
   combine_obj(split_obj(x, n), m)
end
"""

split_combine_post_relate_template = """ 
function divide_n(x::RN=RN(1, 1), n::NN)::RN
   RN(x.num, x.denom * n)
end

function multiply_m(x::RN=RN(1, 1), m::NN)::RN
   RN(x.num * m, x.denom)
end

function divide_n_m(x::RN=RN(1, 1), n::NN, m::NN)::RN
   multiply_m(divide_n(x, n), m) # RN(x.num * m, x.denom * n)
end
"""

RN_template = """ 
function RN_op(x::RN, y::RN, op::Symbol)
   cm = common_multiple(arg1.denominator, arg2.denominator)
   scaled_arg1 = scale(arg1, cm / arg1.denominator)
   scaled_arg2 = scale(arg2, cm / arg2.denominator)
   RN(eval(op)(scaled_arg1.numerator, scaled_arg2.numerator), cm)
end

# subroutines / helpers
function common_multiple(arg1::NN, arg2::NN)
   NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

function scale(rn::RN, nn::NN)
   RN(rn.numerator * nn, rn.denominator * nn, false)
end
"""

variant_RN_template_pre_relate = """
function RN_add(x::RN, y::RN)
    [add_defn]
end

function RN_subtract(x::RN, y::RN)
    [subtract_defn]
end

function RN_compare(x::RN, y::RN, op::Symbol)
    [compare_defn]
end
"""

final_defn = """cm = common_multiple(arg1.denominator, arg2.denominator)
    scaled_arg1 = scale(arg1, cm / arg1.denominator)
    scaled_arg2 = scale(arg2, cm / arg2.denominator)
    RN(eval(op)(scaled_arg1.numerator, scaled_arg2.numerator), cm)
"""

helper_template = """# subroutines / helpers
function common_multiple(arg1::NN, arg2::NN)
   NN(lcm(arg1.value, arg2.value)) # arg1 * arg2
end

function scale(rn::RN, nn::NN)
   RN(rn.numerator * nn, rn.denominator * nn, false)
end
"""

type_translation_functions_str = """
RN(x::NN) = RN(x, NN(1))
"""

function_translation_functions_pre_relate_str = """
RN_op(nn1::NN, nn2::NN, op::Symbol) = RN_op(RN(nn1), RN(nn2))
NN_op(rn1::RN, rn2::RN) = rn1.denom == NN(1) && rn2.denom == NN(1) ? NN_op(NN(rn1), NN(rn2)) : NullNumber 
"""

function_translation_functions_post_relate_str = """
RN_op(nn1::NN, nn2::NN, op::Symbol) = RN_op(RN(nn1), RN(nn2))
NN_op(rn1::RN, rn2::RN) = rn1.denom == NN(1) && rn2.denom == NN(1) ? NN_op(NN(rn1), NN(rn2)) : error("invalid cast") 
"""

function translate_spec_to_type_system(spec, helpers_derivable=false)
    # 1: non-knower
    # 2: halve_obj, double_obj
    # 3: split_obj, combine_obj, divide_obj
    # 4: 3 with relate discovery
    # 5: 4 with arithmetic learned
    # 6: 5 with space infinity
    # 7: 5 with space, number, matter infinity
    # 8: 3 with arithmetic learned 
    # 9: 5 with number infinity
    # 10: 5 with matter infinity 
    # extras: 5, 6, 7, 8, with NN intrusions ("UN," "NN", "RN")

    lang_template = compressed_lang_template 

    if spec["halve1"] == "NullNumber"
        return lang_template
    elseif spec["relate"] == "false"
        lang_template = "$(lang_template)\n$(type_translation_functions_str)"
        lang_template = "$(lang_template)\n$(halve_symbolic_template)"
        for rule in pre_knower_rules[1:end-1] 
            lang_template = "$(lang_template)\n$(string(rule))"
        end
        if spec["divide1"] == "NullNumber"
            return lang_template
        else
            lang_template = "$(lang_template)\n$(split_combine_divide_template)"
            if spec["add_op"] == "NullNumber" && spec["subtract_op"] == "NullNumber" && spec["compare_op"] == "NullNumber"
                return lang_template
            else
                lang_template = "$(lang_template)\n\n$(helper_template)"
                template_arithmetic_defn = variant_RN_template_pre_relate
                
                template_arithmetic_defn = replace(template_arithmetic_defn, "[add_defn]" => join(map(x -> "    $(x)", split(spec["add_op"], "\n")), "\n")[5:end])
                template_arithmetic_defn = replace(template_arithmetic_defn, "[subtract_defn]" => join(map(x -> "    $(x)", split(spec["subtract_op"], "\n")), "\n")[5:end])
                template_arithmetic_defn = replace(template_arithmetic_defn, "[compare_defn]" => join(map(x -> "    $(x)", split(spec["compare_op"], "\n")), "\n")[5:end])

                intrusion_str = "\n\n"
                intrusion_str = "$(intrusion_str)\nfunction RN_add(x::RN, y::RN)\n$(join(map(x -> "    $(x)", split(spec["add_op"], "\n")), "\n"))\nend"

                intrusion_str = "$(intrusion_str)\nfunction RN_subtract(x::RN, y::RN)\n$(join(map(x -> "    $(x)", split(spec["subtract_op"], "\n")), "\n"))\nend"

                intrusion_str = "$(intrusion_str)\nfunction RN_compare(x::RN, y::RN)\n$(join(map(x -> "    $(x)", split(spec["compare_op"], "\n")), "\n"))\nend"

                lang_template = "$(lang_template)\n$(intrusion_str)\n$(string(pre_knower_rules[end]))"
                return lang_template
            end
        end
    else # relate is true
        lang_template = "$(halve_symbolic_template)"
        lang_template = "$(lang_template)\n$(type_translation_functions_str)"
        lang_template = "$(lang_template)\n$(split_combine_post_relate_template)"
        for rule in post_knower_rules[1:end-1] 
            lang_template = "$(lang_template)\n$(string(rule))"
        end
        if !(spec["add_op"] == "NullNumber" && spec["subtract_op"] == "NullNumber" && spec["compare_op"] == "NullNumber")
            lang_template = "$(lang_template)\n$(string(post_knower_rules[end]))"
            if !helpers_derivable 
                lang_template = "$(lang_template)\n\n$(helper_template)"
            end
            num_intrusions = length(intersect(collect(values(selected_NN_intrusions_dict)), [spec["add_op"], spec["subtract_op"], spec["compare_op"]]))
            
            intrusion_str = "\n\n"
            if spec["add_op"] == selected_NN_intrusions_dict["add_op"] || spec["add_op"] == "NullNumber"
                intrusion_str = "$(intrusion_str)\nfunction RN_add(x::RN, y::RN)\n    $(spec["add_op"])\nend"
            end

            if spec["subtract_op"] == selected_NN_intrusions_dict["subtract_op"] || spec["subtract_op"] == "NullNumber"
                intrusion_str = "$(intrusion_str)\nfunction RN_subtract(x::RN, y::RN)\n    $(spec["subtract_op"])\nend"
            end

            if spec["compare_op"] == selected_NN_intrusions_dict["compare_op"] || spec["compare_op"] == "NullNumber"
                intrusion_str = "$(intrusion_str)\nfunction RN_compare(x::RN, y::RN)\n    $(spec["compare_op"])\nend"
            end

            lang_template = "$(lang_template)$(intrusion_str)\n"
        end

        if spec["infinite_divisibility_space"] == "infinite"
            lang_template = "$(lang_template)\ninfinite_divisibility_space = infinite"
        end

        for x in ["number", "weight"]
            val = spec["infinite_divisibility_$(x)"]
            if val != "coarse"
                lang_template = "$(lang_template)\ninfinite_divisibility_$(x) = $(val)"
            end
        end

        lang_template

    end
end

# TODO: handle variants above

lang_str = ""
open("language/macro_compression/compressed/7_abstract_infinite_divisibility_language_compressed.jl", "r") do f 
    global lang_str = read(f, String)
end

# println("\nORIGINAL STRING\n")
# println(lang_str)
# compressed_lang_str = secondary_compression(lang_str, post_knower_rules)

# println("\nCOMPRESSED STRING\n")
# println(lang_str)

# expanded_lang_str = expand(lang_str)
# println("\nEXPANDED STRING")
# println(expanded_lang_str)

# primary_compressed_str = primary_compression(expanded_lang_str, pre_knower_rules)
# println("\nPRIMARY COMPRESSED STRING")
# println(primary_compressed_str)

# secondary_compressed_str = secondary_compression(primary_compressed_str, pre_knower_rules)
# println("\nSECONDARY COMPRESSED STRING")
# println(secondary_compressed_str)


# lang_str = ""
# open("language/macro_compression/compressed/5_rational_arithmetic_understanding_language_compressed.jl", "r") do f 
#     global lang_str = read(f, String)
# end

# # println("\nORIGINAL STRING\n")
# # println(lang_str)
# # compressed_lang_str = secondary_compression(lang_str, post_knower_rules)

# println("\nCOMPRESSED STRING\n")
# println(lang_str)

# expanded_lang_str = expand(lang_str)
# println("\nEXPANDED STRING")
# println(expanded_lang_str)

# primary_compressed_str = primary_compression(expanded_lang_str, post_knower_rules)
# println("\nPRIMARY COMPRESSED STRING")
# println(primary_compressed_str)

# secondary_compressed_str = secondary_compression(primary_compressed_str, post_knower_rules)
# println("\nSECONDARY COMPRESSED STRING")
# println(secondary_compressed_str)


# TODO: what to do about NN_op / RN_op translation function

base_language_names = sort(readdir("language/macro_compression/compressed"), by = x -> parse(Int, split(x, "_")[1]))
language_index_to_knower_rules = Dict([
    1 => [],
    2 => pre_knower_rules[1:end-1],
    3 => pre_knower_rules[1:end-1],
    4 => post_knower_rules[1:end-1],
    5 => post_knower_rules,
    6 => post_knower_rules, 
    7 => post_knower_rules, 
    8 => pre_knower_rules,
    9 => post_knower_rules, 
    10 => post_knower_rules,
])


for i in 11:length(language_names_pretty)
    language_name = language_names_pretty[i]
    if occursin("8_rational_arithmetic_ungrounded_language", language_name)
        language_index_to_knower_rules[i] = pre_knower_rules
    else
        language_index_to_knower_rules[i] = post_knower_rules
    end
end

language_name_to_type_system = Dict()
for i in 1:length(base_language_names)
    language_name = base_language_names[i]
    rules = language_index_to_knower_rules[i]

    println("LANGUAGE NAME: $(language_name)")
    
    global lang_str = ""
    open("language/macro_compression/compressed/$(language_name)", "r") do f 
        global lang_str = read(f, String)
    end
    println("\nCOMPRESSED STRING\n")
    println(lang_str)

    expanded_lang_str = expand(lang_str)
    println("\nEXPANDED STRING")
    println(expanded_lang_str)

    primary_compressed_str = primary_compression(expanded_lang_str, rules)
    println("\nPRIMARY COMPRESSED STRING")
    println(primary_compressed_str)

    secondary_compressed_str = secondary_compression(primary_compressed_str, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

    language_name_to_type_system[language_name] = (secondary_compressed_str, primary_compressed_str, expanded_lang_str)
end

language_name_to_type_system_via_spec = Dict()
for i in 1:length(base_language_names)
    rules = language_index_to_knower_rules[i]
    language_name_ = base_language_names[i] 
    language_name = replace(language_name_, "_compressed.jl" => ".jl")
    spec = language_name_to_definition_spec[language_name]
    intermediate_rDSL_lang = translate_spec_to_type_system(spec)
    

    println("LANGUAGE NAME: $(language_name)")
    println("\nSTART STRING\n")
    println(intermediate_rDSL_lang)


    secondary_compressed_str = secondary_compression(intermediate_rDSL_lang, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

    expanded_lang_str = expand(lang_str)
    println("\nEXPANDED STRING")
    println(expanded_lang_str)

    primary_compressed_str = primary_compression(expanded_lang_str, rules)
    println("\nPRIMARY COMPRESSED STRING")
    println(primary_compressed_str)

    secondary_compressed_str = secondary_compression(primary_compressed_str, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

   language_name_to_type_system_via_spec[language_name] = (secondary_compressed_str, primary_compressed_str, expanded_lang_str) 
end

language_name_to_type_system_via_spec = Dict()
for i in 1:length(language_names_pretty)
    rules = language_index_to_knower_rules[i]
    language_name = language_names_pretty[i]
    # language_name = replace(language_name_, "_compressed.jl" => ".jl")
    spec = language_name_to_definition_spec[language_name]
    intermediate_rDSL_lang = translate_spec_to_type_system(spec)

    println("LANGUAGE NAME: $(language_name)")
    println("\nSTART STRING\n")
    println(intermediate_rDSL_lang)

    secondary_compressed_str = secondary_compression(intermediate_rDSL_lang, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

    expanded_lang_str = expand(lang_str)
    println("\nEXPANDED STRING")
    println(expanded_lang_str)

    primary_compressed_str = primary_compression(expanded_lang_str, rules)
    println("\nPRIMARY COMPRESSED STRING")
    println(primary_compressed_str)

    secondary_compressed_str = secondary_compression(primary_compressed_str, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

   language_name_to_type_system_via_spec[language_name] = (secondary_compressed_str, primary_compressed_str, expanded_lang_str) 
end

rules = []

spec = language_name_to_definition_spec[language_names_pretty[1]]
intermediate_rDSL_lang = translate_spec_to_type_system(spec)

println("LANGUAGE NAME: $(language_name)")
println("\nSTART STRING\n")
println(intermediate_rDSL_lang)

secondary_compressed_str = secondary_compression(intermediate_rDSL_lang, rules)
println("\nSECONDARY COMPRESSED STRING")
println(secondary_compressed_str)

expanded_lang_str = expand(secondary_compressed_str)
println("\nEXPANDED STRING")
println(expanded_lang_str)

primary_compressed_str = primary_compression(expanded_lang_str, rules)
println("\nPRIMARY COMPRESSED STRING")
println(primary_compressed_str)

secondary_compressed_str = secondary_compression(primary_compressed_str, rules)
println("\nSECONDARY COMPRESSED STRING")
println(secondary_compressed_str)

function generate_type_system(language_index, helpers_derivable=false; return_init=false)
    rules = language_index_to_knower_rules[language_index]
    spec = language_name_to_definition_spec[language_names_pretty[language_index]]
    intermediate_rDSL_lang = translate_spec_to_type_system(spec, helpers_derivable)
    
    println("LANGUAGE NAME: $(language_name)")
    println("\nSTART STRING\n")
    println(intermediate_rDSL_lang)

    secondary_compressed_str = secondary_compression(intermediate_rDSL_lang, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

    expanded_lang_str = expand(secondary_compressed_str)
    println("\nEXPANDED STRING")
    println(expanded_lang_str)

    primary_compressed_str = primary_compression(expanded_lang_str, rules, helpers_derivable)
    println("\nPRIMARY COMPRESSED STRING")
    println(primary_compressed_str)

    secondary_compressed_str = secondary_compression(primary_compressed_str, rules)
    println("\nSECONDARY COMPRESSED STRING")
    println(secondary_compressed_str)

    if return_init 
        (intermediate_rDSL_lang, expanded_lang_str, primary_compressed_str, secondary_compressed_str) 
    else
       (expanded_lang_str, primary_compressed_str, secondary_compressed_str) 
    end
end

function generate_all_type_systems(helpers_derivable=false; return_init=false)
    d = Dict()
    for i in 1:length(language_names_pretty)
        type_system = generate_type_system(i, helpers_derivable, return_init=return_init)
        d[language_names_pretty[i]] = type_system
    end 
    d
end

for helpers_derivable in [false, true]
    d = generate_all_type_systems(helpers_derivable, return_init=true)

    for k in keys(d)
        result = d[k] 
        folder_names = readdir("language/macro_compression/auto_generated_variant/helpers_derivable")
        for i in 1:length(folder_names)
            folder_name = folder_names[i]
            helper_derivable_folder = helpers_derivable ? "helpers_derivable" : "helpers_not_derivable" 
            open("language/macro_compression/auto_generated_variant/$(helper_derivable_folder)/$(folder_name)/$(k)", "w+") do f 
                write(f, result[i])
            end
        end
    end
end