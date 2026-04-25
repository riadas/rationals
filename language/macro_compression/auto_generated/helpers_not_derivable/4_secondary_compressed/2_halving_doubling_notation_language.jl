@generalize RN NN


function halve_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Subtract(n, n - 1)))
end

function double_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Add(1, m - 1)))
end

RN(x::NN) = RN(x, NN(1))

function halve(x::RN=RN(1, 1))::RN
    divide_n(x, 2)
end

function double(x::RN=RN(1, 1))::RN
    multiply_m(x, m)
end

@relate RN Divide

@relate RN Subtract (arg1 < arg2)