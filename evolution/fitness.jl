function fitness(routes, traveltimes)
    traveltime = 0
    for route in routes
        prevpatient = 0 # Start with depot
        for patient in route
            traveltime += traveltimes[prevpatient + 1, patient + 1] # All intermediate travel times
            prevpatient = patient
        end
        traveltime += traveltimes[prevpatient + 1, 1] # End with return back to depot
    end
    return traveltime
end