include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("offspring.jl")
include("feasibility.jl")
include("../utils/visualize.jl")

function genetic_algorithm(instance, population_size=100, generations=100, elitism_frac=0.1, p_crossover=0.9, p_mutate=0.01)
    fitness_history = []

    # Initialize population
    population = initialize(population_size, instance)
    println(map(x -> isfeasible(x, instance), eachrow(population)))
    # GA loop
    for n in 1:generations
        # Calculate and record fitness
        fitness = population_fitness(population, instance)
        min_fitness = minimum(fitness)
        println("Generation $n | fitness: $min_fitness")
        append!(fitness_history, min_fitness)

        # Produce next generation
        ranking!(population, fitness, elitism_frac)
        crossover!(population, p_crossover)
        mutate!(population, p_mutate)
        
        best_fit = population[argmin(fitness), :]
        visualize(best_fit, instance, fitness_history)
    end

    return population
end