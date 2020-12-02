#!/usr/bin/julia

const r = Int64[]

open("expense-report.txt", "r") do f
    for i in eachline(f)
        push!(r, parse(Int64, i))
    end
end

function find_product2()
    for (o, a) in enumerate(r)
        for i = o+1:length(r)
            if a + r[i] == 2020
                println("Candidates ", a, " and ", r[i])
                return a * r[i]
            end
        end
    end
end

function find_product3()
    for (o, a) in enumerate(r)
        for i = o+1:length(r)
            for j = i+1:length(r)
                if a + r[i] + r[j] == 2020
                    println("Candidates ", a, " and ", r[i], " and ", r[j])
                    return a * r[i] * r[j]
                end
            end
        end
    end
end

println("Product of 2: ", find_product2())
println("Product of 3: ", find_product3())
