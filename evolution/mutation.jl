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
        place_node!(node, copied_individual, instance, 10)
    end
    individual[:] = copied_individual
end

function move_route!(individual, instance)
    copied_individual = copy(individual)
    route_idxs = random_route_idxs(copied_individual)
    start_idx = route_idxs[1]
    end_idx = route_idxs[end]

    left = false
    if start_idx == 1
        end_idx += 1
    elseif end_idx == length(copied_individual)
        start_idx -= 1
    end
    deleteat!(copied_individual, idx)
    insert_idx = rand(findall(x -> x<0, copied_individual))
    individual[:] = copied_individual
end

function mutate!(population, instance, probability=0.01)
    for (i, individual) in enumerate(eachrow(population))
        if rand() < probability
            choice = rand()
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