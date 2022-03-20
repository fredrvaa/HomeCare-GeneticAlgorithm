using Statistics

include("feasibility.jl")
include("initialization.jl")

function traveltime(individual, instance) 
    traveltime = 0
    prevnode = 0 # Start with depot
    for node in individual
        if node < 0
            node = 0
        end
        traveltime += instance[:traveltimes][prevnode + 1, node + 1] # All intermediate travel times
        prevnode = node
    end
    traveltime += instance[:traveltimes][prevnode + 1, 1] # End with return back to depot
    return traveltime
end

function feasibility_penalty(individual, instance)
    n = length(get_infeasible(individual, instance))
    penalty = n*100
    if n > 0
        penalty += 200
    end
    return penalty
end

function penalty(individual, instance)
    return isfeasible(individual, instance) ? 0 : 2000
end

function individual_fitness(individual, instance, penalty_factor=0.9)
    return traveltime(individual, instance) + feasibility_penalty(individual, instance) * penalty_factor
end

function population_fitness(population, instance, penalty_factor=0.9)
    fitness = Vector{Float64}(undef, size(population, 1))
    for (i, individual) in enumerate(eachrow(population))
        fitness[i] = individual_fitness(individual, instance, penalty_factor)
    end
    return fitness
end