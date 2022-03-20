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