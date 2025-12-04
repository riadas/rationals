# PHYSICAL REALM
struct Object 
    size::Number
end

function halve(obj::Object)::Object
    Object(obj.size/2)
end

function divide(obj::Object, keep::Number, split::Number)
    Object(obj.size*keep/split)
end

infinite_divisibility_space = false

# ABSTRACT NUMBER REALM
function halve(num::Number)
    num/2 # halve(Object(num)).size
end

function divide(numerator::Number, denominator::Number)
    numerator/denominator # divide(Object(1), numerator, denominator).size
end

infinite_divisibility_number = false