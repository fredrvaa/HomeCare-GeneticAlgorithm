using IterTools
using Random

function order(parent1, parent2)
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

function edge_crossover(parent1, parent2)
    function create_offspring!(neighbours, chromosome_length)
        offspring = zeros(Int64, chromosome_length)
        node = rand(keys(neighbours))
        delete!(neighbours, node)
        for (k, v) in neighbours
            neighbours[k] = delete!(v, node)
        end
        offspring[1] = node

        for i in 2:chromosome_length            
            min_length = Inf
            node = 0
            for (k, v) in neighbours
                len = length(v)
                if len < min_length
                    min_length = len
                    node = k
                elseif len == min_length && rand() < 0.5
                    node = k
                end
            end
            delete!(neighbours, node)
            for (k, v) in neighbours
                delete!(v, node)
            end
            offspring[i] = node
        end
        return offspring
    end

    chromosome_length = length(parent1)

    # Construct neighbour lists
    neighbours1 = Dict()
    for node in parent1
        neighbours1[node] = Set([])
    end
    for i in 1:chromosome_length
        n1 = i > 1 ? i - 1 : chromosome_length
        n2 = i < chromosome_length ? i + 1 : 1
        push!(neighbours1[parent1[i]], parent1[n1], parent1[n2])
        push!(neighbours1[parent2[i]], parent2[n1], parent2[n2])
    end
    neighbours2 = deepcopy(neighbours1)
    offspring1 = create_offspring!(neighbours1, chromosome_length)
    offspring2 = create_offspring!(neighbours2, chromosome_length)

    return offspring1, offspring2
end

function crossover!(population, probability=0.7)
    for (i, (parent1, parent2)) in enumerate(partition(eachrow(population), 2))
        if rand() < probability
            if rand() < 0.9
                offspring1, offspring2 = order(parent1, parent2)
            else
                offspring1, offspring2 = edge_crossover(parent1, parent2)
            end
            population[2i-1, :] = offspring1
            population[2i, :] = offspring2
        end
    end
end