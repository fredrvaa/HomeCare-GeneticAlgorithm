using JSON3

function get_instance(filepath)
    json_string = read(filepath, String)
    instance = copy(JSON3.read(json_string))
    instance[:traveltimes] = mapreduce(permutedims, vcat, instance[:travel_times]) # Convert to array from vector[vector]
    delete!(instance, :travel_times)
    instance[:patients] = Dict(parse(Int,string(k))=>v  for (k,v) in pairs(instance[:patients])) # Convert keys from Symbol("Int") to Int
    return instance    
end