using JSON3

function traveltime_nodes(node1, node2, instance)
    return instance[:traveltimes][node1 + 1, node2 + 1]
end

function closest_neighbours(node, instance)
    neighbours = sort(1:length(instance[:patients]), by=x -> traveltime_nodes(node, x, instance))
    return neighbours[2:end]
end

function get_instance(filepath)
    json_string = read(filepath, String)
    instance = copy(JSON3.read(json_string))
    instance[:traveltimes] = mapreduce(permutedims, vcat, instance[:travel_times]) # Convert to array from vector[vector]
    delete!(instance, :travel_times)
    instance[:patients] = Dict(parse(Int,string(k))=>v  for (k,v) in pairs(instance[:patients])) # Convert keys from Symbol("Int") to Int
    instance[:closest] = mapreduce(permutedims, vcat, map(p -> closest_neighbours(p, instance), 1:length(instance[:patients])))
    return instance    
end