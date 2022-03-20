using IterTools
using Random

function order(parent1, parent2)
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
    function create_offspring(parent1, parent2, point1, point2, chromosome_length)
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

    chromosome_length = length(parent1)
    point1 = rand(1:(chromosome_length - 1))
    point2 = rand((point1 + 1):chromosome_length)

    offspring1 = create_offspring(parent1, parent2, point1, point2, chromosome_length)
    offspring2 = create_offspring(parent2, parent1, point1, point2, chromosome_length)
    return offspring1, offspring2
end

function position(parent1, parent2)
    offspring1 = copy(parent1)
    offspring2 = copy(parent2)
    for (i, (node1, node2)) in enumerate(zip(offspring1, offspring2))
        if rand() < 0.6 && node1 > 0 && node2 > 0
            offspring1[i] = node2
            offspring2[i] = node1
        end
    end
    return offspring1, offspring2
end

function crossover!(population, probability=0.7)
    for (i, (parent1, parent2)) in enumerate(partition(eachrow(population), 2))
        if rand() < probability
            if rand() < 1
                offspring1, offspring2 = order(parent1, parent2)
            else
                offspring1, offspring2 = position(parent1, parent2)
            end
            population[2i-1, :] = offspring1
            population[2i, :] = offspring2
        end
    end
end