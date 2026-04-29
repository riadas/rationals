function size(x::Expr, infinite_scale=1.0)
    s = 1
    for arg in x.args 
        s += size(arg, infinite_scale)
    end
    s
end

function size(x::Symbol, infinite_scale=1.0)
    x == :infinite ? infinite_scale : 1
end

function size(x::Union{Int, String, Bool, Nothing}, infinite_scale=1.0)
    1
end

function size(x::QuoteNode, infinite_scale=1.0)
    size(x.value, infinite_scale)
end

function size(x::LineNumberNode, infinite_scale=1.0)
    0
end

function compute_size(lang_str; infinite_scale=1.0)
    expr_str = """quote 
        $(lang_str)    
    end
    """

    expr = eval(Meta.parse(expr_str))
    
    size(expr, infinite_scale)
end

function compute_size_of_file(file_path; infinite_scale=1.0)
    global text = ""
    open(file_path, "r") do f 
        global text = read(f, String)
    end

    compute_size(text, infinite_scale=infinite_scale)
end

function normalize(l)
    l = l .- minimum(l)
    l = l ./ maximum(l)
    l
end

function compute_memory_costs_compressed(; infinite_scale=1.0, helpers_derivable=false, normalized=true, param_effects_memory_mod=0.0)
    helpers_derivable_folder = helpers_derivable ? "helpers_derivable" : "helpers_not_derivable"
    directory = "language/macro_compression/auto_generated_variant/$(helpers_derivable_folder)/4_secondary_compressed/"
    filenames = language_names_pretty 

    sizes = []
    for filename in filenames
        spec = language_name_to_spec[filename]
        file_path = "$(directory)/$(filename)"
        s = compute_size_of_file(file_path, infinite_scale=infinite_scale)
        if spec["relate"] == "RN"
            s = s * (1.0 + param_effects_memory_mod)
        end
        push!(sizes, s)
    end 

    if normalized 
        normalize(sizes)
    else
        sizes
    end
end