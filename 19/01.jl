using Chain
using Utils

inputfile = "$(replace(@__FILE__, r".jl$" => "")).txt"
load(text = slurp(inputfile)) = @chain text begin
    per_line_parse(Int)
end
fload() = inputfile |> slurp |> load
input = fload()

part1(nums = fload()) = sum(nums) do n
    n ÷ 3 - 2
end

function recursive_sum(n)
    n > 0 || return 0

    re = max(0, n ÷ 3 - 2)
    re + recursive_sum(re)
end

part2(nums = fload()) = sum(recursive_sum, nums)

println("Fuel requirements: ", part1(input))
println("Recursive fuel requirements: ", part2(input))
