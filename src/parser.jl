module Parser
    using ..LibTelnet
    using ..LibTelnet.Events
    @enum ParserState begin
        StateNone
        StateIAC
        StateSubnegotiation
    end
    function parse(input::Vector{UInt8})::Vector{Vector{UInt8}}
        state::ParserState = StateNone
        pointer::UInt = 1 # Pointer into the input
        result::Vector{Vector{UInt8}} = [] # Resulting IAC events
        buffer::Vector{UInt8} = [] # Intermediate buffer
        function purge()::Bool
            if length(buffer) > 0
                temp::Vector{UInt8} = Vector{UInt8}(undef, length(buffer))
                copy!(temp, buffer)
                push!(result, temp)
                buffer = []
                return true
            end
            return false
        end
        while pointer < length(input)
            byte::UInt8 = input[pointer]
            if state == StateNone
                # Check for IAC
                if byte == LibTelnet.Commands.IAC
                    # Check if this is escaped
                    if input[pointer + 1] == LibTelnet.Commands.IAC
                        # Escaped, add 0xff to the buffer
                        push!(buffer, byte)
                        pointer += 1
                    else
                        # Not escaped, enter IAC and purge the buffer
                        purge()
                        push!(buffer, byte)
                        state = StateIAC
                    end
                else
                    # Not an IAC event, buffer it
                    push!(buffer, byte)
                end
            elseif state == StateIAC
                if byte == LibTelnet.Commands.GA
                    # Go Ahead, only 2 bytes
                    push!(buffer, byte)
                    purge()
                    state = StateNone
                elseif byte == LibTelnet.Commands.SB
                    # Subnegotiation
                    push!(buffer, byte, input[pointer + 1])
                    pointer += 1
                    state = StateSubnegotiation
                else
                    # Negotiation
                    push!(buffer, byte, input[pointer + 1])
                    pointer += 1
                    purge()
                    state = StateNone
                end
            elseif state == StateSubnegotiation
                window::UInt8 = input[pointer + 1]
                if byte == LibTelnet.Commands.IAC && window == LibTelnet.Commands.SE
                    # End of Subnegotiation
                    push!(buffer, byte, window)
                    purge()
                    state = StateNone
                    pointer+=1
                else
                    push!(buffer, byte)
                end
            end
            pointer += 1
        end
        purge() # Empty the buffer if there is something left
        return result
    end
    function parse_events(input::Vector{UInt8})::Vector{Events.TelnetEvent}
        result::Vector{Events.TelnetEvent} = []
        for ev in Parser.parse(input)
            push!(result, ev)
        end
        return result
    end
end