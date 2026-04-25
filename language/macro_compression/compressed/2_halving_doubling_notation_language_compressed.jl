# inconsistent: RN <: NN => conditional translation
RN(x::NN) = RN(x, NN(1))

@generalize RN NN
@relate RN Divide
@relate RN Subtract (arg1 < arg2) # NEW

function halve(x::RN=RN(1, 1))::RN 
    RN(x.num, x.denom * 2)
end

function double(x::RN=RN(1, 1))::RN 
    RN(x.num * 2, x.denom * 2)
end

function halve_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Subtract(n, n - 1)))
end

function double_obj(x::PQ=PQ(Hidden(RN(1, 1))))::PQ
   build(DQ(x, Add(1, m - 1)))
end