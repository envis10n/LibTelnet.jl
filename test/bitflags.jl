using LibTelnet
using Test

@testset "Bitflags" begin
    Bitflags = LibTelnet.Bitflags
    TestA::UInt8 = 1 << 0
    TestB::UInt8 = 1 << 1
    bits::UInt8 = 0x0
    @test bits == 0b00000000
    bits = Bitflags.bitset(bits, TestA | TestB)
    @test bits == 0b00000011
    @test Bitflags.testbit(bits, TestA | TestB)
    bits = Bitflags.bitflip(bits, TestA)
    @test bits == 0b00000010
end