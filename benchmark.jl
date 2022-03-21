using Random

include("utils/file.jl")
include("evolution/genetic_algorithm.jl")
include("utils/convert.jl")
include("evolution/fitness.jl")
include("utils/output.jl")


for i in 0:9
    instance = get_instance("train/train_$i.json")

    datastring = Dates.format(Dates.now(), "yyyy-mm-ddTHH.MM.SS")
    checkpoint_path = "checkpoints/$(instance[:instance_name])-$datastring.txt"

    individual = genetic_algorithm( instance=instance, 
                                    visualize_run=false,
                                    population_size=100, 
                                    n_generations=3000, 
                                    elitism_frac=0.1, 
                                    p_crossover_range=0.4:0.8,
                                    p_mutate=0.98,
                                    n_islands=6, 
                                    migration_frac=0.01, 
                                    migration_interval=25, 
                                    checkpoint_interval=100,
                                    checkpoint_path=checkpoint_path)
    fitness = individual_fitness(individual, instance)

    open("benchmarks/benchmark_$i.txt", "w") do io
        fitness_text = @sprintf("Fitness %.2f", fitness)
        instance_text = @sprintf("%s %.2f%% %.2f", instance[:instance_name], 100 * (1 - instance[:benchmark] / fitness), instance[:benchmark])
        println(io, "$fitness_text | $instance_text")
        print_list(io, tolist(individual))
    end
end