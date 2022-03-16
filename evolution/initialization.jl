using Random
using Clustering

include("feasibility.jl")

function initialize(population_size, n_nurses, traveltimes, capacity_nurse, patients, depot)
    population = Array{Int, 2}(undef, population_size, (length(patients) + n_nurses - 1))

    for i in 1:population_size
        feasible, individual = feasible_individual(n_nurses, traveltimes, capacity_nurse, patients, depot) 
        population[i, :] = individual 
        println(feasible)
    end
    
    return population
end

function distance(i, patients, depot)
    return sqrt((patients[i]["x_coord"] - depot["x_coord"])^2 + (patients[i]["y_coord"] - depot["y_coord"])^2)
end

function feasible_individual(n_nurses, traveltimes, capacity_nurse, patients, depot)
    individual = Vector{Int}(undef, (length(patients) + n_nurses - 1))
    tries = 100
    feasible = false
    #sorted_patient_idx = sort(1:length(patients), by=i -> distance(i, patients, depot), rev=true)
    for t in 1:tries
        sorted_patient_idx = shuffle(1:length(patients))
        handled_patients = []
        new_individual = Vector{Int}()
        for n in 1:n_nurses
            route = []
            for i in sorted_patient_idx
                if i in handled_patients
                    continue
                end

                append!(route, i)
                if route_isfeasible(route, traveltimes, capacity_nurse, patients, depot["return_time"])
                    append!(handled_patients, i)
                else
                    pop!(route)
                end
            end
            if n != n_nurses
                append!(route, -n)
            end
            append!(new_individual, route)
        end

        if length(new_individual) != length(individual)
            continue
        end

        if isfeasible(new_individual, traveltimes, capacity_nurse, patients, depot["return_time"])
            individual = new_individual
            feasible = true
            break
        end
    end
    return feasible, individual
end

function cluster(patients, n_nurses)
    patient_coords = transpose(mapreduce(permutedims, vcat, [[v["x_coord"], v["y_coord"]] for (k, v) in patients]))
    c = kmeans(patient_coords, n_nurses, maxiter=200)
    return c
end