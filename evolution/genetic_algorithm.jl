using Statistics
using Printf

include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("crossover.jl")
include("mutation.jl")
include("feasibility.jl")
include("../utils/visualize.jl")

function step!(population, instance, n_elites, p_crossover, p_mutate)
    fitness = population_fitness(population, instance)
    ranks = sortperm(fitness)

    # Elitism
    elites = population[ranks[1:n_elites], :]

    # Parent selection
    ranking!(population, ranks)

    # Shuffle mating pool and crossover
    population = population[shuffle(1:end), :]

    # Crossover and mutate to create offspring
    crossover!(population, p_crossover)

    mutate!(population, instance, p_mutate)

    #population = mutated
    # Survivor selection
    #crowding!(parents, population, instance, 1)#(1-n/generations))

    # Propagate elites
    fitness = population_fitness(population, instance)
    worst = sortperm(fitness, rev=true)
    population[worst[1:n_elites], :] = elites
end

function genetic_algorithm(instance, population_size=100, generations=100, elitism_frac=0.1, p_crossover=0.9, p_mutate=0.01, crowding_factor=1, mutation_decay=0.001)
    fitness_history = Array{Float64, 2}(undef, (generations, 3))

    # Initialize population
    population = initialize(population_size, instance)
    n_elites = ceil(Int, size(population, 1) * elitism_frac)
    println(map(x -> isfeasible(x, instance), eachrow(population)))
    # GA loop
    for n in 1:generations
        decayed_p_mutate = p_mutate * (1 / (1 + mutation_decay*n))
        # Calculate and record fitness
        fitness = population_fitness(population, instance)
        #println(fitness)
        fitness_history[n, 1] = minimum(fitness)
        fitness_history[n, 2] = maximum(fitness)
        fitness_history[n, 3] = mean(fitness)
        best_fit = population[argmin(fitness), :]
        visualize(best_fit, instance, fitness_history[1:n, :])
        fitness_text = @sprintf("Fitness %.2f", fitness_history[n, 1])
        instance_text = @sprintf("%s %.2f%% %.2f", instance[:instance_name], 100 * (1 - instance[:benchmark] / fitness_history[n, 1]), instance[:benchmark])
        println("Generation $n | $fitness_text | $instance_text")

        ranks = sortperm(fitness)

        # Elitism
        elites = population[ranks[1:n_elites], :]

        # Parent selection
        ranking!(population, ranks)

        # Shuffle mating pool and crossover
        population = population[shuffle(1:end), :]
        parents = copy(population)

        # Crossover and mutate to create offspring
        crossover!(population, p_crossover)

        mutate!(population, instance, decayed_p_mutate)

        #population = mutated
        # Survivor selection
        #crowding!(parents, population, instance, 1)#(1-n/generations))

        # Propagate elites
        fitness = population_fitness(population, instance)
        worst = sortperm(fitness, rev=true)
        population[worst[1:n_elites], :] = elites
    end

    return population
end