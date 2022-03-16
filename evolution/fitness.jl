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

function population_fitness(population, traveltimes, capacity_nurse, patients, return_time)
    fitness = Vector{Float64}(undef, size(population, 1))
    for (i, individual) in enumerate(eachrow(population))
        feasibility = isfeasible(individual, traveltimes, capacity_nurse, patients, return_time) ? 0 : 3000
        fitness[i] = - (traveltime(individual, traveltimes) + feasibility)
    end
    return fitness
end