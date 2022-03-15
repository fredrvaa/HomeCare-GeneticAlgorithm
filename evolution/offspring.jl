using IterTools

function crossover!(population, probability=0.7)
    """
    Order crossover
    
    Example:

    5 patients, 3 nurses
    ---------------------
    1 2 -1 | 3 -2 4 | 5 (p1)
    4 -2 2 | -1 1 3 | 5 (p2)
    ========================
    2 -1 1 | 3 -2 4 | 5 (o1)
    2 -2 4 | -1 1 3 | 5 (o2)
    """

    function create_offspring(parent1, parent2, chromosome_length)
        point1 = rand(1:(chromosome_length - 1))
        point2 = rand((point1 + 1):chromosome_length)
        rightshift = chromosome_length - point2
        offspring = zeros(Int64, chromosome_length)
        offspring[point1:point2] = parent1[point1:point2]
        offspring = circshift(offspring, rightshift)
        i = 1
        for c in circshift(parent2, chromosome_length - point2)
            if !(c in offspring) 
                offspring[i] = c
                i += 1
            end
            if i == point1 + rightshift
                break
            end
        end
        return circshift(offspring, point2)
    end

    chromosome_length = length(population[1, :])
    for (parent1, parent2) in partition(eachrow(population), 2)
        if rand() < probability
            offspring1 = create_offspring(parent1, parent2, chromosome_length)
            offspring2 = create_offspring(parent2, parent1, chromosome_length)
            parent1 = offspring1
            parent2 = offspring2
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