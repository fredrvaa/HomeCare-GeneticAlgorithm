using Random

include("utils.jl")

function swap_inside!(individual)
    route_idxs = random_route_idxs(individual)
    i = rand(route_idxs)
    j = rand(route_idxs)
    temp1 = individual[i]
    temp2 = individual[j]
    individual[i] = temp2
    individual[j] = temp1 
end

function swap_outside!(individual)
    route_idxs_1 = random_route_idxs(individual)
    route_idxs_2 = random_route_idxs(individual)
    i = rand(route_idxs_1)
    j = rand(route_idxs_2)
    temp1 = individual[i]
    temp2 = individual[j]
    individual[i] = temp2
    individual[j] = temp1 
end

function move_inside!(individual)
    copied_individual = copy(individual)
    route_idxs = random_route_idxs(copied_individual)
    i = rand(route_idxs)
    j = rand(route_idxs)
    if j > i
        j -= 1
    end
    node = splice!(copied_individual, i)
    insert!(copied_individual, j, node)
end

function move_outside!(individual)
    copied_individual = copy(individual)
    route_idxs = random_route_idxs(copied_individual)
    i = rand(route_idxs)
    j = rand(route_idxs)
    node = splice!(copied_individual, i)
    if j > i
        j -= 1
    end
    insert!(copied_individual, j, node)
    individual[:] = copied_individual
end

function switch!(individual)
    i = rand(1:length(individual))
    j = rand(1:length(individual))
    temp1 = individual[i]
    temp2 = individual[j]
    individual[i] = temp2
    individual[j] = temp1
end

function multiswitch!(individual)
    for i in 1:length(individual)
        if rand() < 0.05
            j = sample(1:length(individual))
            temp1 = individual[i]
            temp2 = individual[j]
            individual[i] = temp2
            individual[j] = temp1
        end
    end
    return individual
end

function reroute!(individual, instance)
    f1 = individual_fitness(individual, instance)
    removed_nodes = []
    copied_individual = copy(individual)
    for i in 1:rand(1:10)
        idx = rand(1:length(copied_individual))

        if copied_individual[idx] < 0 # Force to not select separation node
            continue
        end

        while idx > 1 && copied_individual[idx] > 0 # Move idx to start of route
            idx -= 1
        end

        if copied_individual[idx] < 0 # Move idx to first node on route if separation node
            idx += 1
        end

        start_idx = idx

        while idx < length(copied_individual) && copied_individual[idx] > 0 # Move idx to end of route
            idx += 1
        end

        if copied_individual[idx] < 0 # Move idx to last node on route if separation node
            idx -= 1
        end

        end_idx = idx

        removed_nodes = vcat(removed_nodes, copied_individual[start_idx:end_idx])
        deleteat!(copied_individual, start_idx:end_idx)
    end
    for node in shuffle(removed_nodes)
        place_infeasible!(node, copied_individual, instance)
    end
    f2 = individual_fitness(individual, instance)
    if f2 < f1
        println("reroute $(f2 < f1)")
    end
    individual = copied_individual
    return individual
end

function dropout!(individual, instance)
    removed_nodes = []
    copied_individual = copy(individual)
    l = rand(1:(length(individual) / 2))
    while length(removed_nodes) < l
        idx = rand(1:length(copied_individual))

        if copied_individual[idx] < 0 # Force to not select separation node
            continue
        end
        append!(removed_nodes, splice!(copied_individual, idx))
    end
    for node in shuffle(removed_nodes)
        place_infeasible!(node, copied_individual, instance)
    end
    individual[:] = copied_individual
end

function reverse_route!(individual)
    idx = rand(1:length(copied_individual))
    while copied_individual[idx] < 0
        idx = rand(1:length(copied_individual))
    end

    while idx > 1 && copied_individual[idx] > 0 # Move idx to start of route
        idx -= 1
    end

    if copied_individual[idx] < 0 # Move idx to first node on route if separation node
        idx += 1
    end

    start_idx = idx

    while idx < length(copied_individual) && copied_individual[idx] > 0 # Move idx to end of route
        idx += 1
    end

    if copied_individual[idx] < 0 # Move idx to last node on route if separation node
        idx -= 1
    end

    end_idx = idx

    copied_individual[start_idx:end_idx] = reverse(copied_individual[start_idx:end_idx])
    return copied_individual
end

function mutate!(population, instance, probability=0.01)
    for (i, individual) in enumerate(eachrow(population))
        if rand() < probability
            choice = rand()
            # mutated[i,:] = reverse_route!(individual)
            if choice < 0.20
                swap_inside!(individual)
            elseif choice < 0.40
                swap_outside!(individual)
            elseif choice < 0.60
                move_inside!(individual)
            elseif choice < 0.80
                move_outside!(individual)
            elseif choice < 0.95
                switch!(individual)
            else
                dropout!(individual, instance)
            end
        end
    end
end