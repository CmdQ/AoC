using Chain

const Num = Int64

function subject(base::Num, exponent::Num)
    modulus::Num = 20201227
    @assert (modulus-1)^2 >= 0

    re = 1
    base %= modulus
    while exponent > 0
        if exponent % 2 == 1
            re = (re * base) % modulus
        end
        exponent >>= 1
        base = base^2 % modulus
    end
    re
end

@assert subject(7, 8) == 5764801
@assert subject(7, 11) == 17807724
@assert subject(5764801, 11) == 14897079
@assert subject(17807724, 8) == 14897079

function inverse(base::Num, exponent::Num)
    re = 0
    while true
        subject(base, re) == exponent && return re
        re += 1
    end
end

function ex1(keys::Array{Num})
    log = @chain keys begin
        map(i -> inverse(7, i), _)
    end
    subject(keys[1], log[2])
end

problem = [8184785, 5293040]

println("Encryption key: ", ex1(problem))







using Test

@testset "Combo Breaker" begin
    @testset "example 1" begin
    end

    @testset "results" begin
    end
end
