using Random

include("utils/file.jl")
include("evolution/genetic_algorithm.jl")
include("evolution/feasibility.jl")
include("utils/convert.jl")
include("evolution/fitness.jl")
include("utils/output.jl")

instance_nr = rand(0:9)
instance_nr = 9

instance = get_instance("train/train_$instance_nr.json")

population = genetic_algorithm(instance, true, 100, 3000, 0.1, 0.95, 0.98, 1, 0, 6)
idx = argmin(population_fitness(population, instance))
fittest = population[idx, :]
println(stdout, individual_fitness(fittest, instance))
#print_list(io, tolist(fittest))
