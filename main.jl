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
print_list(stdout, tolist(individual))
