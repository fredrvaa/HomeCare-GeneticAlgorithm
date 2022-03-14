using StatsBase

include("fitness.jl")

function roulette(population, fitness)
    total_fitness = sum(fitness)
    probabilities = map(x -> x / total_fitness, fitness)
    idxs = sample(axes(population, 1), Weights(probabilities), size(population, 1))
    return population[idxs, :]
end