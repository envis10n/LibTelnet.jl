module Bitflags
    bitset(bits::Unsigned, flags::Unsigned)::Unsigned = bits | flags
    bitunset(bits::Unsigned, flags::Unsigned)::Unsigned = bits & flags
    bitflip(bits::Unsigned, flags::Unsigned)::Unsigned = bits ⊻ flags
    testbit(bits::Unsigned, flags::Unsigned)::Bool = (bits & flags) != 0
end