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
    time = 0
    demand = 0
    feasible = true
    prevnode = 0
    for (i, node) in enumerate(individual)
        if node < 0
            time += instance[:traveltimes][prevnode + 1, 1] # Return to depot
            if time > instance[:depot][:return_time] # Constraint 4
                feasible = false
                break
            end
            time = 0 
            demand = 0
            prevnode = 0
            continue
        end
        patient = instance[:patients][node]

        demand += patient[:demand]
        if demand > instance[:capacity_nurse] # Constraint 1
            feasible = false
            break
        end

        time += instance[:traveltimes][prevnode + 1, node + 1]  

        if time < patient[:start_time] # Constraint 3
            time = patient[:start_time]
        end

        time += patient[:care_time]

        if time > (patient[:end_time]) # Constraint 2
            feasible = false
            break
        end

        prevnode = node
    end
    
    return feasible
end

function route_isfeasible(route, instance)
    time = 0
    demand = 0
    feasible = true
    prevnode = 0
    for (i, node) in enumerate(route)
        patient = instance[:patients][node]

        demand += patient[:demand]
        if demand > instance[:capacity_nurse] # Constraint 1
            feasible = false
            break
        end

        time += instance[:traveltimes][prevnode + 1, node + 1]  
        
        if time < patient[:start_time] # Constraint 3
            time = patient[:start_time]
        end

        time += patient[:care_time]

        if time > (patient[:end_time]) # Constraint 2
            feasible = false
            break
        end

        prevnode = node
    end
    
    time += instance[:traveltimes][prevnode + 1, 1] # Return to depot
    if time > instance[:depot][:return_time]
        feasible = false
    end
    return feasible
end