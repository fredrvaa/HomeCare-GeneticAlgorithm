using Statistics

include("feasibility.jl")

function traveltime(individual, traveltimes) 
    traveltime = 0
    prevnode = 0 # Start with depot
    for node in individual
        if node < 0
            node = 0
        end
        traveltime += traveltimes[prevnode + 1, node + 1] # All intermediate travel times
        prevnode = node
    end
    traveltime += traveltimes[prevnode + 1, 1] # End with return back to depot
    return traveltime
end

function population_fitness(population, instance)
    fitness = Vector{Float64}(undef, size(population, 1))
    for (i, individual) in enumerate(eachrow(population))
        penalty = isfeasible(individual, instance) ? 0 : 3000
        fitness[i] = traveltime(individual, instance[:traveltimes]) + penalty
    end
    return fitness
end