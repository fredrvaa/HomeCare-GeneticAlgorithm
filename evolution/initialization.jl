using Random
using Clustering

include("feasibility.jl")

function initialize(population_size, instance)
    population = Array{Int, 2}(undef, population_size, (length(instance[:patients]) + instance[:nbr_nurses] - 1))

    for i in 1:population_size
        feasible, individual = feasible_individual(instance) 
        population[i, :] = individual 
        println(feasible)
    end
    
    return population
end

function distance(i, instance)
    return sqrt((instance[:patients][i][:x_coord] - instance[:depot][:x_coord])^2 + (instance[:patients][i][:y_coord] - instance[:depot][:y_coord])^2)
end

function feasible_individual(instance)
    individual = Vector{Int}(undef, (length(instance[:patients]) + instance[:nbr_nurses] - 1))
    tries = 100
    feasible = false
    #sorted_patient_idx = sort(1:length(patients), by=i -> distance(i, patients, depot), rev=true)
    for t in 1:tries
        sorted_patient_idx = shuffle(1:length(instance[:patients]))
        handled_patients = []
        new_individual = Vector{Int}()
        for n in 1:instance[:nbr_nurses]
            route = []
            for i in sorted_patient_idx
                if i in handled_patients
                    continue
                end

                append!(route, i)
                if route_isfeasible(route, instance)
                    append!(handled_patients, i)
                else
                    pop!(route)
                end
            end
            if n != instance[:nbr_nurses]
                append!(route, -n)
            end
            append!(new_individual, route)
        end

        if length(new_individual) != length(individual)
            continue
        end

        if isfeasible(new_individual, instance)
            individual = new_individual
            feasible = true
            break
        end
    end
    return feasible, individual
end

function cluster(patients, n_nurses)
    patient_coords = transpose(mapreduce(permutedims, vcat, [[v[:x_coord], v[:y_coord]] for (k, v) in patients]))
    c = kmeans(patient_coords, n_nurses, maxiter=200)
    return c
end