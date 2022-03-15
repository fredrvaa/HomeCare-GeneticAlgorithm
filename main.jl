include("evolution/genetic_algorithm.jl")

population = genetic_algorithm("train/train_0.json", 1000, 10000)
display(population)