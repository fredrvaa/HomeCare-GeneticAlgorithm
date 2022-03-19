using Statistics

include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("crossover.jl")
include("mutation.jl")
include("feasibility.jl")
include("../utils/visualize.jl")

function genetic_algorithm(instance, population_size=100, generations=100, elitism_frac=0.1, p_crossover=0.9, p_mutate=0.01, crowding_factor=1, mutation_decay=0.001)
    fitness_history = Array{Float64, 2}(undef, (generations, 3))

    # Initialize population
    population = initialize(population_size, instance)
    println(map(x -> isfeasible(x, instance), eachrow(population)))
    # GA loop
    for n in 1:generations
        decayed_p_mutate = p_mutate * (1 / (1 + mutation_decay*n))
        # Calculate and record fitness
        fitness = population_fitness(population, instance)
        fitness_history[n, 1] = minimum(fitness)
        fitness_history[n, 2] = maximum(fitness)
        fitness_history[n, 3] = mean(fitness)

        println("Generation $n | fitness: $(fitness_history[n, 1])")

        # Parent selection
        ranking!(population, fitness, elitism_frac)

        # Shuffle mating pool and crossover
        population = population[shuffle(1:end), :]
        parents = copy(population)

        # Crossover and mutate to create offspring
        crossover!(population, p_crossover)
        mutate!(population, decayed_p_mutate)
        crowding!(parents, population, instance, crowding_factor)
        
        best_fit = population[argmin(fitness), :]
        visualize(best_fit, instance, fitness_history[1:n, :])
    end

    return population
end