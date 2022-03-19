using StatsBase
using Random

include("fitness.jl")

function roulette!(population, fitness, fraction_keep=0.01)
    population_size = size(population, 1)
    n_keep = ceil(Int, population_size * fraction_keep)
    n_new = population_size - n_keep

    # Store elites
    elites = population[sortperm(fitness)[1:n_keep], :]

    total_fitness = sum(fitness)
    probabilities = map(x -> x / total_fitness, fitness)
    idxs = sample(axes(population, 1), Weights(probabilities), n_new) 

    # Update population
    population[(n_keep + 1):end, :] = population[idxs, :]  
    population[1:n_keep, :] = elites
end

function ranking!(population, fitness, fraction_keep=0.1)
    population_size = size(population, 1)
    n_keep = ceil(Int, population_size * fraction_keep)
    n_new = population_size - n_keep

    ranks = sortperm(fitness)
    # Store elites
    elites = population[ranks[1:n_keep], :]

    total = population_size * (population_size + 1) / 2
    probabilities = map(i -> (population_size - i + 0.5) / total, 1:population_size)
    idxs = sample(ranks, Weights(probabilities), n_new) 

    # Update population
    population[(n_keep + 1):end, :] = population[idxs, :]  
    population[1:n_keep, :] = elites

    return copy(population)
end