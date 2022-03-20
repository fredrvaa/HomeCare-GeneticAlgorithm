using Random

include("utils/file.jl")
include("evolution/genetic_algorithm.jl")
include("utils/convert.jl")
include("evolution/fitness.jl")
include("utils/output.jl")


for i in 0:9
    instance = get_instance("train/train_$i.json")

    individual = genetic_algorithm(instance, false, 100, 3000, 0.1, 0.95, 0.98, 1, 0, 6)

    open("benchmarks/benchmark_$i.txt", "w") do io
        println(io, individual_fitness(individual, instance))
        print_list(io, tolist(individual))
    end
end