include("utils/file.jl")
include("evolution/genetic_algorithm.jl")
include("evolution/feasibility.jl")

instance = get_instance("train/train_2.json")
display(instance)

population = genetic_algorithm(instance, 200, 5000, 0.1, 0.98, 0.005)
println(map(x -> isfeasible(x, instance)))