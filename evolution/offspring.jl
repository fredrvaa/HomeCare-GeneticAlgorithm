using IterTools

function crossover!(population, probability=0.7, n_points=1)
    for (o1, o2) in partition(eachrow(population), 2)
        if rand() < probability
            for n in 1:n_points
                p = rand(1:(length(o1) - 1))
                temp1 = copy(o1[p:end])
                temp2 = copy(o2[p:end])
                o2[p:end] = temp1
                o1[p:end] = temp2
            end
        end
    end
    return population
end

function mutate!(population, probability=0.01)
    for individual in eachrow(population)
        for i in 1:length(individual)
            if rand() < probability
                j = sample(1:length(individual))
                temp1 = individual[i]
                temp2 = individual[j]
                individual[i] = temp2
                individual[j] = temp1
            end
        end
    end
    return population
end