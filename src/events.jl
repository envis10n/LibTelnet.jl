module Events
    import ..LibTelnet
    @enum TelnetEvents begin
        IACEvent
        NegotiationEvent
        SubnegotiationEvent
        DataReceiveEvent
    end
    struct TelnetEvent
        type::TelnetEvents
        command::UInt8
        option::UInt8
        payload::Vector{UInt8}
    end
    Base.convert(::Type{Vector{UInt8}}, ev::TelnetEvent) = begin
        if ev.type == IACEvent
            [0xff, ev.command]
        elseif ev.type == NegotiationEvent
            [0xff, ev.command, ev.option]
        elseif ev.type == SubnegotiationEvent
            cat([0xff, LibTelnet.Commands.SB, ev.option], ev.payload, [0xff, LibTelnet.Commands.SE], dims=1)
        else
            ev.payload
        end
    end
    Base.convert(::Type{TelnetEvent}, buffer::Vector{UInt8}) = begin
        if length(buffer) == 0
            throw("no data")
        else
            temp::Vector{UInt8} = []
            copy!(temp, buffer)
            if buffer[begin] == 0xff && buffer[begin+1] != 0xff
                # IAC event sequence
                if buffer[begin+1] == LibTelnet.Commands.GA
                    # IAC event (GO AHEAD)
                    TelnetEvent(IACEvent, buffer[begin+1], 0, [])
                elseif buffer[begin+1] == LibTelnet.Commands.SB
                    # Subnegotiation
                    if buffer[end-1] == 0xff && buffer[end] == LibTelnet.Commands.SE
                        TelnetEvent(SubnegotiationEvent, buffer[begin+1], buffer[begin+2], buffer[begin+3:end-2])
                    else
                        throw("malformed subnegotiation, or missing data")
                    end
                else
                    # Negotiation
                    TelnetEvent(NegotiationEvent, buffer[begin+1], buffer[begin+2], [])
                end
            else
                # Data
                TelnetEvent(DataReceiveEvent, 0, 0, temp)
            end
        end
    end
    function buildIAC(command::UInt8, option::UInt8)::TelnetEvent
        TelnetEvent(IACEvent, command, option, [])
    end
    function buildSubnegotiation(option::UInt8, payload::Vector{UInt8})::TelnetEvent
        temp::Vector{UInt8} = []
        copy!(temp, payload)
        TelnetEvent(SubnegotiationEvent, LibTelnet.Commands.SB, option, temp)
    end
end