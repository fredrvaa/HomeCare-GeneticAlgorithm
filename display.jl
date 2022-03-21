using Plots

include("utils/convert.jl")
include("utils/file.jl")
include("utils/visualize.jl")
include("utils/output.jl")

instance_path = "train/train_1.json"
checkpoint_path = "checkpoints/train_1-2022-03-21T19.52.53.txt"

instance = get_instance(instance_path)
individual = individual_from_file(checkpoint_path)
display(plot(solution_plot(individual, instance), size=(1000,600)))
print_solution(stdout, individual, instance)