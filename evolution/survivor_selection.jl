using IterTools

include("fitness.jl")

function hamming(individual1, individual2)
    return sum([(x!=y) for (x, y) in zip(individual1, individual2)])
end

function competition(parent, offspring, instance, factor)
    parent_fitness = -individual_fitness(parent, instance)
    offspring_fitness = -individual_fitness(offspring, instance)

    if offspring_fitness > parent_fitness
        offspring_probability = offspring_fitness / (offspring_fitness + factor * parent_fitness)
    elseif offspring_fitness < parent_fitness
        offspring_probability = (factor * offspring_fitness) / (factor * offspring_fitness + parent_fitness)
    else
        offspring_probability = 0.5
    end
    return rand() < offspring_probability ? offspring : parent
end

function crowding!(parents, offspring, instance, factor=1)
    for (i, ((p1, p2), (o1, o2))) in enumerate(zip(partition(eachrow(parents), 2, 2), partition(eachrow(offspring), 2, 2)))
        if hamming(p1, o1) + hamming(p2, o2) < hamming(p1, o2) + hamming(p2, o1)
            o1 = competition(p1, o1, instance, factor)
            o2 = competition(p2, o2, instance, factor)
        else
            o1 = competition(p1, o2, instance, factor)
            o2 = competition(p2, o1, instance, factor)
        end
        offspring[2i-1, :] = o1
        offspring[2i, :] = o2
    end
end