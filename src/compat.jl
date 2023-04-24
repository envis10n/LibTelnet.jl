module Compatibility
    using LibTelnet
    module State
        const Local::UInt8 = 1 << 0
        const Remote::UInt8 = 1 << 1
        const LocalState::UInt8 = 1 << 2
        const RemoteState::UInt8 = 1 << 3
    end
    const CompatibilityTable = Dict{UInt8,UInt8}
    struct CompatibilityEntry
        islocal::Bool
        isremote::Bool
        localstate::Bool
        remotestate::Bool
    end
    Base.convert(::Type{UInt8}, c::CompatibilityEntry) = begin
        temp = 0x0
        if c.islocal
            temp |= State.Local end
        if c.isremote
            temp |= State.Remote end
        if c.localstate
            temp |= State.LocalState end
        if c.remotestate
            temp |= State.RemoteState end
        temp
    end
    Base.convert(::Type{CompatibilityEntry}, v::UInt8) = begin
        CompatibilityEntry(
            Bitflags.testbit(v, State.Local),
            Bitflags.testbit(v, State.Remote),
            Bitflags.testbit(v, State.LocalState),
            Bitflags.testbit(v, State.RemoteState)
        )
    end
    function supportlocal(comp::CompatibilityTable, opt::UInt8)
        cur = haskey(comp, opt) ? comp[opt] : 0x0
        comp[opt] = Bitflags.bitset(cur, State.Local)
    end
    function supportremote(comp::CompatibilityTable, opt::UInt8)
        cur = haskey(comp, opt) ? comp[opt] : 0x0
        comp[opt] = Bitflags.bitset(cur, State.Remote)
    end
    function support(comp::CompatibilityTable, opt::UInt8)
        cur = haskey(comp, opt) ? comp[opt] : 0x0
        comp[opt] = Bitflags.bitset(cur, State.Local | State.Remote)
    end
    function entry(comp::CompatibilityTable, opt::UInt8)::CompatibilityEntry
        if !haskey(comp, opt)
            comp[opt] = 0x0 end
        comp[opt]
    end
    supportlocal(comp::CompatibilityTable, opt::Number) = supportlocal(comp, UInt8(opt))
    supportremote(comp::CompatibilityTable, opt::Number) = supportremote(comp, UInt8(opt))
    support(comp::CompatibilityTable, opt::Number) = support(comp, UInt8(opt))
    entry(comp::CompatibilityTable, opt::Number) = entry(comp, UInt8(opt))
end