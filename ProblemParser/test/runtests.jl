using ProblemParser
using Test

@testset "Convert" begin
    @test parse(Convert(), "42") == 42
    @test typeof(parse(Convert(UInt8), "42")) == UInt8
end

@testset "Lines" begin
    one_string_per_line = """
        Python
        Julia
        Racket
        """

    @test parse(Lines(), one_string_per_line) == ["Python", "Julia", "Racket"]

    one_number_per_line = """
        11
        1657
        355
        769
        1981
        """

    @test parse(Lines(Convert(Int)), one_number_per_line) == [11,1657,355,769,1981]
end

@testset "Split" begin
    @testset "without mapping" begin
        @test parse(Split(), "1 2 3") == ["1", "2", "3"]
        @test parse(Split(), "1   2 3 ") == ["1", "2", "3"]
        @test parse(Split(keepempty=true), "1   2 3 ") == ["1", "", "", "2", "3", ""]
    end
    @testset "with mapping" begin
        @test parse(Split(Convert()), "1 2 3") == [1, 2, 3]
        @test parse(Split(Convert()), "1   2 3 ") == [1, 2, 3]
    end

    @testset "ragged lines" begin
        ragged_numbers = """
            1,2,3
            1
            1,2,3,4
            """

        @test parse(Lines(Split(",")), ragged_numbers) == [["1","2","3"], ["1"], ["1","2","3","4"]]
        @test parse(Lines(Split(",", Convert(Int))), ragged_numbers) == [[1,2,3], [1], [1,2,3,4]]
    end
end

@testset "Rectangular" begin
    string_map2d = """
        #....
        .#..#
        .....
        """

    @test parse(Rectangular(), string_map2d) == ['#' '.' '.' '.' '.'; '.' '#' '.' '.' '#'; '.' '.' '.' '.' '.']

    number_map2d = """
        08888
        80880
        80808
        12345
        """

    @test parse(Rectangular(Convert(Int)), number_map2d) == [0 8 8 8 8; 8 0 8 8 0; 8 0 8 0 8; 1 2 3 4 5]

    number_map2d_separator = """
        1,2,3
        2,3,4
        3,4,5
        """

    @test parse(Rectangular(Lines(Split(",", Convert(Int)))), number_map2d_separator) == [1 2 3; 2 3 4; 3 4 5]
end

@testset "Blocks" begin
    blocks_of_string = """
        efokjptizdcwmqnuh
        qgfdvurtnjwpichxk
        taqkcunfzpmydiwjsh

        mzbg
        tmg
        rlvge
        hgpbzn
        cagkijyu
        """

    @test parse(Blocks(), blocks_of_string) == [
        "efokjptizdcwmqnuh\nqgfdvurtnjwpichxk\ntaqkcunfzpmydiwjsh",
        "mzbg\ntmg\nrlvge\nhgpbzn\ncagkijyu\n",
    ]

    @test parse(Blocks(Lines()), blocks_of_string) == [
        [
            "efokjptizdcwmqnuh",
            "qgfdvurtnjwpichxk",
            "taqkcunfzpmydiwjsh"
        ],
        [
            "mzbg",
            "tmg",
            "rlvge",
            "hgpbzn",
            "cagkijyu"
        ],
    ]

    blocks_of_numbers = """
        1

        2
        3
        5
        7

        1
        4
        9
        """

    @test parse(Blocks(Lines(Convert(Int))), blocks_of_numbers) == [[1], [2, 3, 5, 7], [1, 4, 9]]
end

@testset "FirstRest" begin
    first_rest = """
        header
        1,2,3
        1
        1,2,3,4
        """

    @test parse(FirstRest(), first_rest) == ("header", "1,2,3\n1\n1,2,3,4\n")
    @test parse(FirstRest(Lines(), Lines(Split(",", Convert(Int)))), first_rest) == ("header", [[1,2,3],[1],[1,2,3,4]])

    first_rest_blocks = """
        tl,tr
        bl,br

        1,2
        2,3
        """

    @test parse(FirstRest(Blocks(), Lines(Split(",")), Lines(Split(",", Convert()))), first_rest_blocks) == ([["tl", "tr"], ["bl", "br"]], [[1, 2], [2, 3]])

    target_with_mappings =
    """
        NOCS

        NO -> B
        PV -> P
        OC -> K
        SC -> K
        """

    @test parse(FirstRest(Blocks(), Lines(Split(" -> "))), target_with_mappings) == ("NOCS", [["NO", "B"], ["PV", "P"], ["OC", "K"], ["SC", "K"]])

end

@testset "Mappings" begin
    complex = """
        3-4 h: hrht
        5-7 g: pmtgqgg
        8-10 k: kklxkkkqkkkkk
        """

    @test parse(Lines(Split()), complex) == [
        ["3-4", "h:", "hrht"],
        ["5-7", "g:", "pmtgqgg"],
        ["8-10", "k:", "kklxkkkqkkkkk"],
    ]

    @test parse(LineMappings(Split(": ")), complex) == Dict(
        "5-7 g"  => "pmtgqgg",
        "8-10 k" => "kklxkkkqkkkkk",
        "3-4 h"  => "hrht",
    )

    @test parse(LineMappings(Split(": "), Split(), nothing), complex) == Dict(
        ["5-7", "g"]  => "pmtgqgg",
        ["8-10", "k"] => "kklxkkkqkkkkk",
        ["3-4", "h"]  => "hrht",
    )

    @test parse(LineMappings(Split(": "), FirstRest(Split(" "), Split("-", Convert()), nothing), nothing), complex) == Dict(
        ([5, 7], "g")  => "pmtgqgg",
        ([8, 10], "k") => "kklxkkkqkkkkk",
        ([3, 4], "h")  => "hrht",
    )
end
