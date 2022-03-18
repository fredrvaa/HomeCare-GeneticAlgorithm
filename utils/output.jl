using Printf
include("convert.jl")

function print_solution(io, individual, instance)
    println(io, "\nNurse capacity: $(instance[:capacity_nurse])")
    println(io, "Depot return time: $(instance[:depot][:return_time])")
    println(io, "----------------------------------------")
    route_list = tolist(individual)
    patients = instance[:patients]
    total_time = 0
    for (i, route) in enumerate(route_list)
        traveltime = 0
        time = 0
        demand = 0
        route_string = "D (0)"
        prevnode = 0
        for node in route
            patient = patients[node]
            time += instance[:traveltimes][prevnode + 1, node + 1]
            traveltime += instance[:traveltimes][prevnode + 1, node + 1]
            arrive_time = time
            if time < patient[:start_time]
                time = patient[:start_time]
            end
            time += patient[:care_time]
            leave_time = time

            demand += patient[:demand]
            route_string *= @sprintf(" -> %d (%.2f-%.2f)[%.2f-%.2f]", node, arrive_time, leave_time, patient[:start_time], patient[:end_time])
            prevnode = node
        end
        traveltime += instance[:traveltimes][prevnode + 1, 1]
        route_string *= " -> D ($time)"
        println(io, @sprintf("Nurse %d \t %.2f \t %.2f \t %s", i, traveltime, demand, route_string))
        total_time += traveltime
    end
    println(io, "----------------------------------------")
    println(io, "Objective value (total duration): $total_time")
end