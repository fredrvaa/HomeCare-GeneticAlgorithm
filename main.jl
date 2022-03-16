using JSON3

include("evolution/genetic_algorithm.jl")
include("evolution/feasibility.jl")
include("evolution/fitness.jl")
include("evolution/initialization.jl")

# Read instance from path
json_string = read("train/train_0.json", String)
instance = JSON3.read(json_string)

n_nurses = instance["nbr_nurses"]
traveltimes = mapreduce(permutedims, vcat, instance["travel_times"])
capacity_nurse = instance["capacity_nurse"]
patients = instance["patients"]
return_time = instance["depot"]["return_time"]
depot = instance["depot"]

population = genetic_algorithm(instance, 200, 3000)
println(map(x -> isfeasible(x, traveltimes, capacity_nurse, patients, return_time), eachrow(population)))