function isfeasible(individual, instance)
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
    traveltimes = mapreduce(permutedims, vcat, instance["travel_times"])
    capacity_nurse = instance["capacity_nurse"]
    patients = instance["patients"]
    return_time = instance["depot"]["return_time"]

    time = 0
    demand = 0
    feasible = true
    prevnode = 1
    for node in individual
        if node < 0
            if time > return_time # Constraint 4
                println("return time")
                feasible = false
                break
            end
            time = 0 
            demand = 0
            prevnode = 1
            continue
        end
        patient = patients[node]

        demand += patient["demand"]
        if demand > capacity_nurse # Constraint 1
            println("demand")
            feasible = false
            break
        end

        time += traveltimes[prevnode + 1, node + 1]
        if time > (patient["end_time"] - patient["care_time"]) # Constraint 2
            feasible = false
            println("Time window")
            break
        end

        if time < patient["start_time"] # Constraint 3
            time = patient["start_time"]
        end
    end
    
    return feasible
end