using Utils
using Underscores

const Mappings = Dict{String,String}

function parse_file(f)
    @_ split(f) |> map(Dict(split(item, ':') for item=split(_)), __)
end

function load()
    open(aoc"04_passports", "r") do f
        parse_file(f)
    end
end

function isvalid(d)
    isempty(setdiff(Set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]), keys(d)))
end

colors = Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])

function fd(s, fromto)
    parsed = tryparse(UInt, s)
    if isnothing(parsed)
        false
    else
        parsed in fromto
    end
end

function isvalid_strict(d)
    try
        fd(d["byr"], 1920:2020) &&
            fd(d["iyr"], 2010:2020) &&
            fd(d["eyr"], 2020:2030) &&
            d["ecl"] in colors &&
            occursin(r"^#[0-9a-f]{6}$", d["hcl"]) &&
            occursin(r"^\d{9}$", d["pid"]) &&
            occursin(r"^(1([5-8]\d|9[0-3])cm|(59|6\d|7[0-6])in)$", d["hgt"])
    catch KeyError
        false
    end
end

function count_valid(isvalid, passports)
    @_ sum(isvalid(_) ? 1 : 0, passports)
end

passports = load()

println("Number of          valid passports: ", count_valid(isvalid, passports))
println("Number of striclty valid passports: ", count_valid(isvalid_strict, passports))





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

        example = parse_file(IOBuffer(example_input))

        @test example == expected

        @test isvalid(example[1])
        @test !isvalid(example[2])
        @test isvalid(example[3])
        @test !isvalid(example[4])
    end

    @testset "example 2 valid" begin
        passports = parse_file(IOBuffer("""
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

        @test (@_ all(isvalid_strict(_), passports))
    end

    @testset "example 2 invalid" begin
        passports = parse_file(IOBuffer("""
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

        @test !(@_ any(isvalid_strict(_), passports))
    end

    @testset "TDD" begin
        first = passports[1]
        @test length(first) == 6
    end

    @testset "results" begin
        @test count_valid(isvalid, passports) == 222
        @test count_valid(isvalid_strict, passports) == 140
    end
end