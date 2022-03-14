function individual_fitness(individual, traveltimes)
    traveltime = 0
    prevnode = 1 # Start with depot
    for node in individual
        traveltime += traveltimes[prevnode + 1, node + 1] # All intermediate travel times
        prevnode = node
    end
    traveltime += traveltimes[prevnode + 1, 1] # End with return back to depot
    return 1 / traveltime
end

function population_fitness(population, traveltimes)
    fitness = Vector{Float64}(undef, size(population, 1))
    for (i, individual) in enumerate(eachrow(population))
        fitness[i] = individual_fitness(individual, traveltimes)
    end
    return fitness
end