using Random

include("utils/file.jl")
include("evolution/genetic_algorithm.jl")
include("utils/convert.jl")
include("evolution/fitness.jl")
include("utils/output.jl")


for i in 0:9
    instance = get_instance("train/train_$i.json")

    individual = genetic_algorithm(instance, false, 150, 3000, 0.05, 0.95, 0.98, 1, 0, 6, 0.01, 25)
    fitness = individual_fitness(individual, instance)

    open("benchmarks/benchmark_$i.txt", "w") do io
        fitness_text = @sprintf("Fitness %.2f", fitness)
        instance_text = @sprintf("%s %.2f%% %.2f", instance[:instance_name], 100 * (1 - instance[:benchmark] / fitness), instance[:benchmark])
        println(io, "$fitness_text | $instance_text")
        print_list(io, tolist(individual))
    end
end