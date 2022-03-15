using JSON3

include("evolution/genetic_algorithm.jl")
include("evolution/feasibility.jl")

# Read instance from path
json_string = read("train/train_0.json", String)
instance = JSON3.read(json_string)

population = genetic_algorithm(instance, 100, 5)
println(map(x -> isfeasible(x, instance), eachrow(population)))