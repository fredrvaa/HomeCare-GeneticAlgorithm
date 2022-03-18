function tolist(individual)
    output = []
    route = []
    for node in individual
        if node < 0
            push!(output, route)
            route = []
            continue
        end
        push!(route, node)
    end
    push!(output, route)
    return output
end

function print_list(io, v::AbstractVector)
	print(io, "[")
	for (i, elt) in enumerate(v)
			i > 1 && print(io, ", ")
			if elt isa AbstractVector
				print_list(io, elt)
			else
				print(io, elt)
			end
	end
	print(io, "]")
end