using LibTelnet
using Test

@testset "Parser" begin
    input::Vector{UInt8} = [0xff, 0xf9, 0xff, 0xfb, 0xc9] # IAC GA, IAC WILL GMCP
    res = LibTelnet.Parser.parse(input)
    @test (length(res) == 2) && (res[1] == [0xff, 0xf9]) && (res[2] == [0xff, 0xfb, 0xc9])
    res = LibTelnet.Parser.parse_events(input)
    @test (length(res) == 2) && (res[1].type == Events.IACEvent)
end