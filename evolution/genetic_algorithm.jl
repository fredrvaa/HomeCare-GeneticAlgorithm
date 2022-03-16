include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("offspring.jl")
include("../utils/visualize.jl")

function genetic_algorithm(instance, population_size=100, n_generations=100)
    fitness_history = []

    # Initialize population
    population = initialize(population_size, instance)
    # GA loop
    for n in 1:n_generations
        # Calculate and record fitness
        fitness = population_fitness(population, instance)
        min_fitness = minimum(fitness)
        println("Generation $n | fitness: $min_fitness")
        append!(fitness_history, min_fitness)

        # Produce next generation
        ranking!(population, fitness, 0.01)
        crossover!(population, 0.9)
        mutate!(population, 0.001)
        
        best_fit = population[argmax(fitness), :]
        visualize(best_fit, instance, fitness_history)
    end

    return population
end