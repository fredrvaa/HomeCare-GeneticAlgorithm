using StatsBase
using Random

include("fitness.jl")

function roulette!(population, fitness)
    total_fitness = sum(fitness)
    probabilities = map(x -> x / total_fitness, fitness)
    idxs = sample(axes(population, 1), Weights(probabilities), n_new) 

    # Update population
    population[(n_keep + 1):end, :] = population[idxs, :]  
    population[1:n_keep, :] = elites
end

function ranking!(population, ranks)
    population_size = size(population, 1)

    total = population_size * (population_size + 1) / 2
    probabilities = map(i -> (population_size - i + 0.5) / total, 1:population_size)
    idxs = sample(ranks, Weights(probabilities), population_size) 
    population .= population[idxs, :] 
end