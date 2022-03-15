using Statistics

function traveltime(individual, traveltimes) 
    traveltime = 0
    prevnode = 1 # Start with depot
    for node in individual
        if node < 0
            node = 1
        end
        traveltime += traveltimes[prevnode + 1, node + 1] # All intermediate travel times
        prevnode = node
    end
    traveltime += traveltimes[prevnode + 1, 1] # End with return back to depot
    return traveltime
end

function population_fitness(population, traveltimes)
    fitness = Vector{Float64}(undef, size(population, 1))
    for (i, individual) in enumerate(eachrow(population))
        fitness[i] = traveltime(individual, traveltimes)
    end
    fitness = exp.(-(fitness .- mean(fitness)))
    return fitness
end