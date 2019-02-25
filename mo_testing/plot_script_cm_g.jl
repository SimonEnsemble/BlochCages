using JLD2
using CSV
using DataFrames
using PyPlot

# Pass in the following command line arguments for this plotting script to work
# 1. the name of the .jld2 file to open for plotting
# 2. the name of the csv experimental data
# 3. the name of the structure being used
# 4. the name of the .png file the plot will be saved as

# Pass the jld2 file as the first CLA
input_file = ARGS[1]

@load input_file results density
mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]

# Converted mmol/g -> cm^3 STP/cm^3
# (mmol) * (22.4 L STP) * (1000 cm^3) = (22.4) (cm^3 STP)
# ( g  )   (1000 mmol )   (    L    )          (    g   )

vstpg = mmolg .* (22.4)
pressures = [results[i]["pressure (bar)"] for i = 1:length(results)]

df = CSV.File(ARGS[2]) |> DataFrame

grid(true, linestyle="--", zorder=0) # the grid will be present
#set_axisbelow(true)
plot(pressures, vstpg, label="Simulated " * ARGS[3], color=:blue, marker="o", zorder=1000) # simulated data
scatter(df[1], df[2], label="Experimental " * ARGS[3], color=:orange, marker="^", zorder=1000)
xlabel("Pressure (bar)")
ylabel(L"Methane Adsorbed (cm$^3$/g)") 
title("Adsorption Isotherm for " * ARGS[3]) # plot is labelled based on structure name
legend(loc=4) # legend will display in the lower right

# Pass the output file as the second CLA
savefig(ARGS[4], dpi=300)
