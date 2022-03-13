import JSON3

include("./evolution/fitness.jl")

json_string = read("train/train_0.json", String)
instance = JSON3.read(json_string)

patients = instance["patients"]
traveltimes = mapreduce(permutedims, vcat, instance["travel_times"])
routes = [range(1 + 20(x-1), 20(x)) for x in range(1,5)]

f = fitness(routes, traveltimes)
println(f)