function isfeasible(individual, traveltimes, capacity_nurse, patients, return_time)
    """
    Checks if individual solution is feasible.

    A solution must comply with the following constraints:
    1. Nurses can not take on more work than `capacity_nurse`
    2. Nurses must spend `care_time` in patients time window (between `start_time` and `end_time`)
    3. If a nurse arrives before a patients `start_time`, he will wait until `start_time`
    4. Nurses must be back at depot before depots `return_time`

    # Arguments
    - `individual::Vector{Int64}`: Individual to check feasibility for
    - `instance::Dict`: Instance dictionary containing constraints
    """
    time = 0
    demand = 0
    feasible = true
    prevnode = 0
    for (i, node) in enumerate(individual)
        #println("---- Node $i: $node -----")
        #println("time $time, demand $demand")
        if node < 0
            if time > return_time # Constraint 4
                #println("return time")
                feasible = false
                break
            end
            time = 0 
            demand = 0
            prevnode = 0
            continue
        end
        patient = patients[node]

        demand += patient["demand"]
        if demand > capacity_nurse # Constraint 1
            #println("demand")
            feasible = false
            break
        end
        traveltime = traveltimes[prevnode + 1, node + 1] 
        time += traveltime 
        start_time, end_time, care_time = patient["start_time"], patient["end_time"], patient["care_time"]
        #println("traveltime $traveltime, start_time $start_time, end_time $end_time, care_time $care_time")
        if time > (end_time - care_time) # Constraint 2
            feasible = false
            #println("Time window $time $end_time $care_time")
            break
        end

        if time < start_time # Constraint 3
            time = start_time
        end

        time += care_time

        prevnode = node
    end
    
    return feasible
end

function route_isfeasible(route, traveltimes, capacity_nurse, patients, return_time)
    time = 0
    demand = 0
    feasible = true
    prevnode = 0
    for (i, node) in enumerate(route)
        patient = patients[node]

        demand += patient["demand"]
        if demand > capacity_nurse # Constraint 1
            #println("demand")
            feasible = false
            break
        end
        traveltime = traveltimes[prevnode + 1, node + 1] 
        time += traveltime 
        start_time, end_time, care_time = patient["start_time"], patient["end_time"], patient["care_time"]
        #println("traveltime $traveltime, start_time $start_time, end_time $end_time, care_time $care_time")
        if time > (end_time - care_time) # Constraint 2
            feasible = false
            #println("Time window $time $end_time $care_time")
            break
        end

        if time < start_time # Constraint 3
            time = start_time
        end

        time += care_time

        prevnode = node
    end
    
    time += traveltimes[prevnode + 1, 1]
    if time > return_time
        feasible = false
        #println("return_time")
    end
    return feasible
end