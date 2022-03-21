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

function toindividual(list)
    individual = Vector{Int}()
    for (i, route) in enumerate(list)
        if i > 1
            append!(individual, -i+1)
        end
        for node in route
            append!(individual, node)
        end
    end
    return individual
end