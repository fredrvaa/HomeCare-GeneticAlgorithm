using Plots

function visualize_individual(individual, instance)
    patients = instance["patients"]
    coords = [[v["x_coord"], v["y_coord"]] for (k, v) in patients]
    depot_x = instance["depot"]["x_coord"]
    depot_y = instance["depot"]["y_coord"]

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
        append!(x, coords[node][1])
        append!(y, coords[node][2])
    end
    plot!(p, [depot_x], [depot_y], label="Depot", markershape=:square, markersize=5, seriestype=:scatter)
    display(p)
end