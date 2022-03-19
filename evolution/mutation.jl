using Random

function switch!(individual)
    i = rand(1:length(individual))
    j = rand(1:length(individual))
    temp1 = individual[i]
    temp2 = individual[j]
    individual[i] = temp2
    individual[j] = temp1
    return individual
end

function multiswitch!(individual)
    for i in 1:length(individual)
        if rand() < 0.05
            j = sample(1:length(individual))
            temp1 = individual[i]
            temp2 = individual[j]
            individual[i] = temp2
            individual[j] = temp1
        end
    end
    return individual
end

function mutate!(population, probability=0.01)
    for individual in eachrow(population)
        if rand() < probability
            if rand() < 0.8
                switch!(individual)
            else
                multiswitch!(individual)
            end
        end
    end
    return population
end