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
    n_elites::Int
end

function step!(population, fitness, instance, params)
    # Keep feasible solutions in case they have to be propagated
    feasible_idx = findall(!iszero, population_feasiblity(population, instance))
    prefeasible = population[feasible_idx, :]

    # Elitism
    ranks = sortperm(fitness)
    elites = population[ranks[1:params.n_elites], :]

    # Parent selection
    ranking!(population, ranks)

    # Shuffle mating pool and crossover
    population[:] = population[shuffle(1:end), :]
    #parents = copy(population)

    # Crossover and mutate to create offspring
    crossover!(population, params.p_crossover)

    mutate!(population, instance, params.p_mutate)

    # Crowding
    #crowding!(parents, population, instance, 1)#(1-n/generations))

    # Propagate elites
    fitness = population_fitness(population, instance)
    worst = sortperm(fitness, rev=true)
    population[worst[1:params.n_elites], :] = elites

    # Make sure feasible are kept
    n_postfeasible = length(findall(!iszero, population_feasiblity(population, instance)))
    if n_postfeasible < 5
        n_replace = 5 - n_postfeasible

        prefeasible_fitness = population_fitness(prefeasible, instance)
        best_prefeasible = sortperm(prefeasible_fitness)
        population[worst[params.n_elites+1:params.n_elites+n_replace], :] = prefeasible[best_prefeasible[1:n_replace], :]
    end
end

function genetic_algorithm(;instance, 
                            visualize_run=true,
                            population_size=100, 
                            n_generations=100, 
                            elitism_frac=0.05, 
                            p_crossover_range=0.7:0.7,
                            p_mutate=0.98, 
                            n_islands=6, 
                            migration_frac=0.01, 
                            migration_interval=25, 
                            checkpoint_interval=100,
                            checkpoint_path="checkpoints/default.txt")
    # Initialize constants
    datastring = Dates.format(Dates.now(), "yyyy-mm-ddTHH.MM.SS")
    checkpoint_path = "checkpoints/$(instance[:instance_name])-$datastring.txt"
    individual_size = length(instance[:patients]) + instance[:nbr_nurses] - 1
    n_elites = ceil(Int, population_size * elitism_frac)
    n_migrations = ceil(Int, population_size * migration_frac)

    # Initialize islands of populations
    islands = Array{Int, 3}(undef, n_islands, population_size, individual_size)
    island_params = Vector{PopulationParams}(undef, n_islands)
    crossover_step = (p_crossover_range[end] - p_crossover_range[1])/n_islands
    @threads for i in 1:n_islands
        islands[i,:,:] = initialize(population_size, instance) 
        p_crossover = p_crossover_range[1] + crossover_step*(i-1)
        island_params[i] = PopulationParams(p_crossover, p_mutate, n_elites)
    end

    fitness_history = Array{Float64, 2}(undef, (n_generations, 3))
    best_individual = Vector{Int}(undef, individual_size)
    # GA loop
    iter = ProgressBar(1:n_generations)
    for n in iter
        fitness_history[n, 1] = Inf
        fitness_history[n, 2] = Inf
        fitness_history[n, 3] = Inf

        # Progress each island one generation
        @threads for i in 1:n_islands
            # Record fitness and best individual
            population = @view islands[i,:,:]
            fitness = population_fitness(population, instance)
            feasible_idx = findall(!iszero, population_feasiblity(population, instance))
            feasible_population = population[feasible_idx, :]
            feasible_fitness = population_fitness(feasible_population, instance)
            min_feasible_fitness = minimum(feasible_fitness)
            if min_feasible_fitness < fitness_history[n, 1]
                fitness_history[n, 1] = min_feasible_fitness # Minimum should be feasible
                fitness_history[n, 2] = maximum(fitness) # Max can be infeasible
                fitness_history[n, 3] = mean(fitness) # Mean can be infeasible
                best_individual = feasible_population[argmin(feasible_fitness), :]
            end
            step!(population, fitness, instance, island_params[i])
        end

        # Migrate individual between islands
        if n % migration_interval == 0
            islands_copy = copy(islands)
            for i in 1:n_islands
                island = copy(islands[i,:,:])
                island_fitness = population_fitness(island, instance)
                worst = sortperm(island_fitness, rev=true)
                n_migrated = 0
                other_islands = islands[1:n_islands .!= i,:,:]
                for j in 1:n_islands-1
                    other_island = other_islands[j, :, :]
                    other_fitness = population_fitness(other_island, instance)
                    best = sortperm(other_fitness)
                    island[worst[1+n_migrated:n_migrations+n_migrated],:,:] = other_island[best[1:n_migrations],:,:]
                    n_migrated += n_migrations
                end
                islands_copy[i,:,:] = island
            end
            islands[:] = islands_copy
        end

        # Save best individual to file
        if n % checkpoint_interval == 0
            open(checkpoint_path, "a") do io
                println(io, "Generation $n")
                print_list(io, tolist(best_individual))
                println(io, "")
                println(io, best_individual)
            end
        end

        # Visualize and print stats for (previous) generation
        if visualize_run
            visualize(best_individual, instance, fitness_history[1:n, :])
        end
        fitness_text = @sprintf("Fitness %.2f", fitness_history[n, 1])
        instance_text = @sprintf("%s %.2f%% %.2f", instance[:instance_name], 100 * (1 - instance[:benchmark] / fitness_history[n, 1]), instance[:benchmark])
        set_description(iter, "Generation $n | $fitness_text | $instance_text")
    end

    return best_individual
end