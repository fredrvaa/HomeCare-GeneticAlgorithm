using Random

function initialize(population_size, n_nurses=25, n_patients=100)
    population = Array{Int, 2}(undef, population_size, (n_patients + n_nurses - 1))

    patients = 1:n_patients
    for i in 1:population_size
        individual = shuffle(patients)
        for n in 1:(n_nurses - 1)
            insert!(individual, rand(1:(n_patients + n - 1)), 0)
        end
        population[i, :] = individual
    end
    
    return population
end
