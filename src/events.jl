module Events
    import ..LibTelnet
    @enum TelnetEvent::UInt8 begin
        IAC
        Negotiation
        Subnegotiation
        DataReceive
        DataSend
        DataDecompress
    end
    struct TelnetIAC
        command::UInt8
    end
    struct TelnetNegotiation
        command::UInt8
        option::UInt8
    end
    struct TelnetSubnegotiation
        option::UInt8
        payload::Vector{UInt8}
    end
end