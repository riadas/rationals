function size(x::Expr)
    s = 1
    for arg in x.args 
        s += size(arg)
    end
    s
end

function size(x::Symbol)
    1
end

function size(x::Union{Int, String, Bool, Nothing})
    1
end

function size(x::QuoteNode)
    size(x.value)
end

function size(x::LineNumberNode)
    0
end

function compute_size(lang_str, dir_prefix="")
    file_str = """global expr = quote 
        $(lang_str)    
    end
    """

    open("language/macro_compression/size_computation_scratch.jl", "w+") do f 
        write(f, file_str)
    end

    include("$(dir_prefix)size_computation_scratch.jl")
    
    size(expr)
end

function compute_size_of_file(file_path)
    global text = ""
    open(file_path, "r") do f 
        global text = read(f, String)
    end

    compute_size(text)
end

directory = "language/macro_compression/auto_generated_variant/helpers_not_derivable/4_secondary_compressed/"
filenames = language_names_pretty 

sizes = []
for filename in filenames
    file_path = "$(directory)/$(filename)"
    s = compute_size_of_file(file_path)
    push!(sizes, s)
end 

function normalize(l)
    l = l .- minimum(l)
    l = l ./ maximum(l)
    l
end

normalized_sizes = normalize(sizes)