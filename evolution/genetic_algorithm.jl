using Statistics
using Printf
using Base.Threads

include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("crossover.jl")
include("mutation.jl")
include("feasibility.jl")
include("../utils/visualize.jl")

function step!(population, fitness, instance, n_elites, p_crossover, p_mutate)
    ranks = sortperm(fitness)

    # Elitism
    elites = population[ranks[1:n_elites], :]

    # Parent selection
    ranking!(population, ranks)

    # Shuffle mating pool and crossover
    population[:] = population[shuffle(1:end), :]

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

function genetic_algorithm(instance, visualize_run=true, population_size=100, generations=100, elitism_frac=0.05, p_crossover=0.9, p_mutate=0.01, crowding_factor=1, mutation_decay=0.001, islands=3, migration_frac=0.01, migration_interval=25)
    individual_size = (length(instance[:patients]) + instance[:nbr_nurses] - 1)
    fitness_history = Array{Float64, 2}(undef, (generations, 3))
    populations = Array{Int, 3}(undef, islands, population_size, individual_size)
    # Initialize population
    @threads for i in 1:islands
        populations[i,:,:] = initialize(population_size, instance)
    end

    n_elites = ceil(Int, population_size * elitism_frac)
    n_migrations = ceil(Int, population_size * migration_frac)
    best_fit = Vector{Int}(undef, individual_size)
    # GA loop
    for n in 1:generations
        fitness_history[n, 1] = Inf
        fitness_history[n, 2] = Inf
        fitness_history[n, 3] = Inf
        best_fit = nothing
        @threads for i in 1:islands
            # Record fitness
            population = @view populations[i,:,:]
            fitness = population_fitness(population, instance)
            min_island_fitness = minimum(fitness)
            if min_island_fitness < fitness_history[n, 1]
                fitness_history[n, 1] = min_island_fitness
                fitness_history[n, 2] = maximum(fitness)
                fitness_history[n, 3] = mean(fitness)
                best_fit = population[argmin(fitness), :]
            end
            step!(population, fitness, instance, n_elites, p_crossover, p_mutate)
        end

        if n % migration_interval == 0
            populations_copy = copy(populations)
            for i in 1:islands
                island = copy(populations[i,:,:])
                island_fitness = population_fitness(island, instance)
                worst = sortperm(island_fitness, rev=true)
                n_migrated = 0
                other_islands = populations[1:islands .!= i,:,:]
                for other_island in eachslice(other_islands, dims=1)
                    other_fitness = population_fitness(other_island, instance)
                    best = sortperm(other_fitness)
                    island[worst[1+n_migrated:n_migrations+n_migrated],:,:] = other_island[best[1:n_migrations],:,:]
                    n_migrated += n_migrations
                end
                populations_copy[i,:,:] = island
            end
            populations = populations_copy
        end

        # Visualize and print stats for (previous) generation
        if visualize_run
            visualize(best_fit, instance, fitness_history[1:n, :])
        end
        fitness_text = @sprintf("Fitness %.2f", fitness_history[n, 1])
        instance_text = @sprintf("%s %.2f%% %.2f", instance[:instance_name], 100 * (1 - instance[:benchmark] / fitness_history[n, 1]), instance[:benchmark])
        println("Generation $n | $fitness_text | $instance_text")
    end

    return best_fit
end