include("utils/file.jl")
include("evolution/genetic_algorithm.jl")
include("evolution/feasibility.jl")

instance = get_instance("train/train_0.json")
display(instance)

population = genetic_algorithm(instance, 200, 500)
println(map(x -> isfeasible(x, instance)