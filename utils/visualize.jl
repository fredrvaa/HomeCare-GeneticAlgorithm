using Plots

function solution_plot(individual, instance)
    depot_x = instance[:depot][:x_coord]
    depot_y = instance[:depot][:y_coord]

    x = [depot_x]
    y = [depot_y]
    p = plot(title="Fittest individual", legend=:outertopright)
    n = 1
    for node in individual
        if node < 0
            append!(x, depot_x)
            append!(y, depot_y)
            unused_nurse = length(y) == 2
            if unused_nurse
                plot!(p, x, y, label="Nurse $n (unused)", markershape=:circle, markercolor=:grey, linecolor=:grey)
            else
                plot!(p, x, y, label="Nurse $n", markershape=:circle)
            end
            x = [depot_x]
            y = [depot_y]
            n += 1
            continue
        end
        append!(x, instance[:patients][node][:x_coord])
        append!(y, instance[:patients][node][:y_coord])
    end
    plot!(p, [depot_x], [depot_y], label="Depot", markershape=:square, markersize=5, seriestype=:scatter)
    return p
end

function fitness_plot(fitness_history)
    return plot(1:length(fitness_history), fitness_history, title="Minimum fitness", label="Fittest individual", xlabel="Generation", ylabel="Fitness")
end

function visualize(individual, instance, fitness_history)
    p1 = solution_plot(individual, instance)
    p2 = fitness_plot(fitness_history)
    display(plot(p1, p2, layout=(1,2), size=(1600,600)))
end