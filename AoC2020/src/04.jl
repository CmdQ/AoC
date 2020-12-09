#!/usr/bin/julia

function parse(f)::Array{Dict{String,String}}
    d = Dict{String,String}()
    re = Array{typeof(d),1}()
    for line in eachline(f)
        if isempty(line)
            push!(re, d)
            d = Dict{String,String}()
        else
            for tuple in split(line)
                k, v = split(tuple, ':')
                d[k] = v
            end
        end
    end
    push!(re, d)
    re
end

function isvalid(d::Dict{String,String})
    isempty(setdiff(Set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]), keys(d)))
end

colors = Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])

function fd(s, fromto)
    try
        parse(UInt, s) in fromto
    catch ArgumentError
        false
    end
end

function fdt(s, fromto)
    parsed = tryparse(UInt, s)
    if isnothing(parsed)
        false
    else
        parsed in fromto
    end
end

function isvalid_strict(d::Dict{String,String})
    try
        bools = [
            fd(d["byr"], 1920:2020),
            fd(d["iyr"], 2010:2020),
            fd(d["eyr"], 2020:2030),
            d["ecl"] in colors,
            occursin(r"^#[0-9a-f]{6}$", d["hcl"]),
            occursin(r"^\d{9}$", d["pid"]),
            occursin(r"^(1([5-8]\d|9[0-3])cm|(59|6\d|7[0-6])in)$", d["hgt"]),
        ]
        println("DEBUG: ", bools)
        all(bools)
    catch KeyError
        false
    end
end

sample = Dict(
    "hcl" => "#623a2f",
    "ecl" => "grn",
    "pid" => "087499704",
    "hgt" => "74in",
    "iyr" => "2012",
    "eyr" => "2030",
    "byr" => "1980",
)

println("Sample is ", isvalid_strict(sample))
@assert fd("2010", 2000:2020) == fdt("2010", 2000:2020)
println("after assert")









using Test

@testset "Passport Processing" begin
    @testset "example 1" begin
        example_input = """
            ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
            byr:1937 iyr:2017 cid:147 hgt:183cm

            iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
            hcl:#cfa07d byr:1929

            hcl:#ae17e1 iyr:2013
            eyr:2024
            ecl:brn pid:760753108 byr:1931
            hgt:179cm

            hcl:#cfa07d eyr:2025 pid:166559648
            iyr:2011 ecl:brn hgt:59in
            """
        expected = [
            Dict(
                "ecl" => "gry",
                "pid" => "860033327",
                "eyr" => "2020",
                "hcl" => "#fffffd",
                "byr" => "1937",
                "iyr" => "2017",
                "cid" => "147",
                "hgt" => "183cm",
            ),
            Dict(
                "iyr" => "2013",
                "ecl" => "amb",
                "cid" => "350",
                "eyr" => "2023",
                "pid" => "028048884",
                "hcl" => "#cfa07d",
                "byr" => "1929",
            ),
            Dict(
                "hcl" => "#ae17e1",
                "iyr" => "2013",
                "eyr" => "2024",
                "ecl" => "brn",
                "pid" => "760753108",
                "byr" => "1931",
                "hgt" => "179cm",
            ),
            Dict(
                "hcl" => "#cfa07d",
                "eyr" => "2025",
                "pid" => "166559648",
                "iyr" => "2011",
                "ecl" => "brn",
                "hgt" => "59in",
            ),
        ]

        example = parse(IOBuffer(example_input))

        @test example == expected

        @test isvalid(example[1])
        @test !isvalid(example[2])
        @test isvalid(example[3])
        @test !isvalid(example[4])
    end

    @testset "example 2 valid" begin
        passports = parse(IOBuffer("""
            pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
            hcl:#623a2f

            eyr:2029 ecl:blu cid:129 byr:1989
            iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

            hcl:#888785
            hgt:164cm byr:2001 iyr:2015 cid:88
            pid:545766238 ecl:hzl
            eyr:2022

            iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
            """))


        for p in passports
            @assert !isvalid_strict(p) p
        end
        @test all(p -> isvalid_strict(p), passports)
    end

    @testset "example 2 invalid" begin
        passports = parse(IOBuffer("""
            eyr:1972 cid:100
            hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

            iyr:2019
            hcl:#602927 eyr:1967 hgt:170cm
            ecl:grn pid:012533040 byr:1946

            hcl:dab227 iyr:2012
            ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

            hgt:59cm ecl:zzz
            eyr:2038 hcl:74454a iyr:2023
            pid:3556412378 byr:2007
            """))

        @test !any(p -> isvalid_strict(p), passports)
    end
end