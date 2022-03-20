using Statistics
using Printf
using ProgressBars
using Base.Threads
using Dates

include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("crossover.jl")
include("mutation.jl")
include("feasibility.jl")
include("../utils/visualize.jl")
include("../utils/convert.jl")

struct PopulationParams
    p_crossover::Float64
    p_mutate::Float64
    mutation_decay::Float64
    n_elites::Int
end

function step!(population, fitness, instance, params)
    ranks = sortperm(fitness)
    prefeasible = population[findall(population_feasiblity(population, instance)), :]
    # Elitism
    elites = population[ranks[1:params.n_elites], :]

    # Parent selection
    ranking!(population, ranks)

    # Shuffle mating pool and crossover
    population[:] = population[shuffle(1:end), :]
    #parents = copy(population)

    # Crossover and mutate to create offspring
    crossover!(population, params.p_crossover)

    mutate!(population, instance, params.p_mutate)

    # Survivor selection
    #crowding!(parents, population, instance, 1)#(1-n/generations))

    # Propagate elites
    fitness = population_fitness(population, instance)
    worst = sortperm(fitness, rev=true)
    population[worst[1:params.n_elites], :] = elites

    # Make sure feasible are kept
    n_postfeasible = length(findall(population_feasiblity(population, instance)))
    if n_postfeasible < 1
        println("Infeasible")
        population[worst[n_elites+1], :] = prefeasible[ranks[1], :]
    end
end

function genetic_algorithm(instance, visualize_run=true, population_size=100, generations=100, elitism_frac=0.05, p_crossover=0.9, p_mutate=0.01, crowding_factor=1, mutation_decay=0.001, islands=3, migration_frac=0.01, migration_interval=25, checkpoint_interval=100)
    datastring = Dates.format(Dates.now(), "yyyy-mm-ddTHH.MM.SS")
    checkpoint_path = "checkpoints/$(instance[:instance_name])-$datastring.txt"
    println(checkpoint_path)
    individual_size = (length(instance[:patients]) + instance[:nbr_nurses] - 1)
    n_elites = ceil(Int, population_size * elitism_frac)
    n_migrations = ceil(Int, population_size * migration_frac)

    # Initialize islands of populations
    populations = Array{Int, 3}(undef, islands, population_size, individual_size)
    island_params = Vector{PopulationParams}(undef, islands)
    @threads for i in 1:islands
        populations[i,:,:] = initialize(population_size, instance)
        island_params[i] = PopulationParams(rand(0.5:0.95), 1, 0, n_elites)
    end

    fitness_history = Array{Float64, 2}(undef, (generations, 3))
    best_fit = Vector{Int}(undef, individual_size)
    # GA loop
    iter = ProgressBar(1:generations)
    for n in iter
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
            step!(population, fitness, instance, island_params[i])
        end

        if n % migration_interval == 0
            populations_copy = copy(populations)
            for i in 1:islands
                island = copy(populations[i,:,:])
                island_fitness = population_fitness(island, instance)
                worst = sortperm(island_fitness, rev=true)
                n_migrated = 0
                other_islands = populations[1:islands .!= i,:,:]
                for j in 1:islands-1
                    other_island = other_islands[j, :, :]
                    other_fitness = population_fitness(other_island, instance)
                    best = sortperm(other_fitness)
                    island[worst[1+n_migrated:n_migrations+n_migrated],:,:] = other_island[best[1:n_migrations],:,:]
                    n_migrated += n_migrations
                end
                populations_copy[i,:,:] = island
            end
            populations[:] = populations_copy
        end

        if n % checkpoint_interval == 0
            checkpoint_solution = nothing
            solution_fitness = Inf
            for i in 1:islands
                population = populations[i,:,:]
                feasible = population[findall(population_feasiblity(population, instance)),:] 
                fitness = population_fitness(feasible, instance)
                if minimum(fitness) < solution_fitness
                    checkpoint_solution = population[argmin(fitness), :]
                    solution_fitness = minimum(fitness)
                end
            end
            open(checkpoint_path, "a") do io
                println(io, "Generation $n")
                print_list(io, tolist(checkpoint_solution))
                println(io, "")
            end
        end

        # Visualize and print stats for (previous) generation
        if visualize_run
            visualize(best_fit, instance, fitness_history[1:n, :])
        end
        fitness_text = @sprintf("Fitness %.2f", fitness_history[n, 1])
        instance_text = @sprintf("%s %.2f%% %.2f", instance[:instance_name], 100 * (1 - instance[:benchmark] / fitness_history[n, 1]), instance[:benchmark])
        set_description(iter, "Generation $n | $fitness_text | $instance_text")
    end

    solution = nothing
    solution_fitness = Inf
    for i in 1:islands
        population = populations[i,:,:]
        feasible = population[findall(population_feasiblity(population, instance)),:] 
        fitness = population_fitness(feasible, instance)
        if minimum(fitness) < solution_fitness
            solution = population[argmin(fitness), :]
            solution_fitness = minimum(fitness)
        end
    end

    return solution
end