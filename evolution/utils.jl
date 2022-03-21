function random_route_idxs(individual)
    idx = rand(1:length(individual))

    while individual[idx] < 0 # Force to not select separation node
        idx = rand(1:length(individual))
    end

    while idx > 1 && individual[idx] > 0 # Move idx to start of route
        idx -= 1
    end

    if individual[idx] < 0 # Move idx to first node on route if separation node
        idx += 1
    end

    start_idx = idx

    while idx < length(individual) && individual[idx] > 0 # Move idx to end of route
        idx += 1
    end

    if individual[idx] < 0 # Move idx to last node on route if separation node
        idx -= 1
    end

    end_idx = idx

    return start_idx:end_idx
end

function place_node!(node, individual, instance, n)
    closest = shuffle(instance[:closest][node, 1:n])
    placed = false
    for neighbour in closest
        if placed
            break
        end

        idx = findfirst(x -> x==neighbour, individual)
        if idx !== nothing
            while idx > 1 && individual[idx] > 0 # Move idx to start of route
                idx -= 1
            end

            if individual[idx] < 0 # Move idx to first node on route if separation node
                idx += 1
            end

            start_idx = idx

            while idx < length(individual) && individual[idx] > 0 # Move idx to end of route
                idx += 1
            end

            if individual[idx] < 0 # Move idx to last node on route if separation node
                idx -= 1
            end

            end_idx = idx

            route = individual[start_idx:end_idx]
            for insert_idx in reverse(start_idx:end_idx)
                insert!(route, (insert_idx - start_idx + 1), node)
                if route_isfeasible(route, instance)
                    insert!(individual, insert_idx, node)
                    placed = true
                    break
                else
                    splice!(route, (insert_idx - start_idx + 1))
                end 
            end

        end 
    end

    if !placed
        idx = length(individual)
        for rnode in reverse(individual)
            if rnode > 0
                idx += 2
                break
            end
            idx -= 1
        end
        if idx >= length(individual)
            append!(individual, node)
        elseif idx <= 0
            pushfirst!(individual, node)
        else 
            insert!(individual, idx, node)
        end
        placed = true
    end
    return placed
end