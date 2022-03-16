using Plots

for i in 1:10
    x = 1:10; y = rand(10); # These are the plotting data
    plt = plot()
    display(plot(x, y))
    sleep(0.5)
end