using Random
using Clustering

include("feasibility.jl")

function initialize(population_size, instance)
    population = Array{Int, 2}(undef, population_size, (length(instance[:patients]) + instance[:nbr_nurses] - 1))

    for i in 1:population_size
        println("Generating individual $i...")
        individual = feasible_individual(instance) 
        population[i, :] = individual 
    end
    
    return population
end

function traveltime_nodes(node1, node2, instance)
    return instance[:traveltimes][node1 + 1, node2 + 1]
end

function closest_neighbours(node, instance)
    neighbours = sort(1:length(instance[:patients]), by=x -> traveltime_nodes(node, x, instance))
    return neighbours[2:end]
end

function semifeasible(instance)
    individual = Vector{Int}(undef, (length(instance[:patients]) + instance[:nbr_nurses] - 1))
    closest = mapreduce(permutedims, vcat, map(p -> closest_neighbours(p, instance), 1:length(instance[:patients])))

    unassigned = trues(length(instance[:patients]))
    i = 1
    for n in 1:(instance[:nbr_nurses]-1)
        idxs = findall(unassigned)
        if (length(idxs) != 0)
            node = rand(idxs)
            unassigned[node] = 0
            individual[i] = node
            i += 1
            demand = instance[:patients][node][:demand]
            for neighbour in closest[node, :]
                if !unassigned[neighbour] || rand() < 0.01
                    continue
                end

                new_demand = demand + instance[:patients][neighbour][:demand] 
                if new_demand < instance[:capacity_nurse]
                    demand = new_demand
                    unassigned[neighbour] = 0
                    individual[i] = neighbour
                    i += 1
                else
                    continue
                end
            end
        end
        individual[i] = -n
        i += 1
    end
    return individual
end

function sort_by_endtime!(individual, instance)
    route = []
    i = 1
    for node in individual
        if node < 0
            route = sort(route, by=x -> instance[:patients][x][:start_time])
            route_length = length(route)
            individual[i:(i+route_length-1)] = route
            i += (route_length + 1)
            route = []
            continue
        end
        append!(route, node)
    end
    return individual
end

function get_infeasible(individual, instance)
    idxs = []
    time = 0
    prevnode = 0
    for (i, node) in enumerate(individual)
        if node < 0
            time = 0
            prevnode = 0
            continue
        end

        patient = instance[:patients][node]
        new_time = time + instance[:traveltimes][prevnode + 1, node + 1]
        if new_time < patient[:start_time]
            new_time = patient[:start_time]
        end
        new_time += patient[:care_time] 
        
        if (new_time > patient[:end_time]) || ((new_time + instance[:traveltimes][node + 1, 1]) > instance[:depot][:return_time])
            append!(idxs, i)
            continue
        end

        time = new_time
        prevnode = node
    end
    return idxs
end

function place_infeasible!(node, individual, instance)
    closest = closest_neighbours(node, instance)
    placed = false
    for neighbour in closest
        if placed
            break
        end

        idxs = findall(x -> x==neighbour, individual)
        if length(idxs) > 0
            idx = idxs[1]
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
            for insert_idx in start_idx:end_idx
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
        else 
            insert!(individual, idx, node)
        end
        placed = true
    end
    return placed
end

function make_feasible!(individual, instance)
    sort_by_endtime!(individual, instance)
    infeasible_idxs = get_infeasible(individual, instance)
    infeasible = individual[infeasible_idxs]
    deleteat!(individual, infeasible_idxs)
    for node in infeasible
        place_infeasible!(node, individual, instance)
    end
end

function feasible_individual(instance)
    individual = semifeasible(instance)
    make_feasible!(individual, instance)
    return individual
end

