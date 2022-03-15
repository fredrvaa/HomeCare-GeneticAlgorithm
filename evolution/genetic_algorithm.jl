using JSON3

include("initialization.jl")
include("fitness.jl")
include("parent_selection.jl")
include("survivor_selection.jl")
include("offspring.jl")

function genetic_algorithm(instance_path, population_size=100, n_generations=100)
    # Read instance from path
    json_string = read(instance_path, String)
    instance = JSON3.read(json_string)
    traveltimes = mapreduce(permutedims, vcat, instance["travel_times"])

    fitness_log = []

    # Initialize population
    population = initialize(population_size, instance["nbr_nurses"], length(instance["patients"]))
    # GA loop
    for n in 1:n_generations
        # Calculate and record fitness
        fitness = population_fitness(population, traveltimes)
        max_fitness = maximum(fitness)
        println("Generation $n | fitness: $max_fitness")
        append!(fitness_log, sum(fitness))

        # Produce next generation
        ranking!(population, fitness, 0.01)
        crossover!(population)
        mutate!(population, 0.01)
    end

    return population
end