using JLD2
using PyPlot

# Pass in the following command line arguments for this plotting script to work
# 1. the name of the .jld2 file to open for plotting
# 2. the name of the structure being used
# 3. the name of the .png file the plot will be saved as

# Pass the jld2 file as the first CLA
input_file = ARGS[1]

@load input_file results

mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]
pressures = [results[i]["fugacity (bar)"] for i = 1:length(results)]

grid(true, linestyle="--", zorder=0) # the grid will be present
#set_axisbelow(true)
scatter(pressures, mmolg, label=ARGS[2], color=:blue, marker="o", zorder=1000) # line is labelled based on structure name
xlabel("Pressure (bar)")
ylabel(L"$\langle$N$\rangle$ (mmol/g)") 
title("Adsorption Isotherm for " * ARGS[2]) # plot is labelled based on structure name
legend(loc=4) # legend will display in the lower right

# Pass the output file as the second CLA
savefig(ARGS[3], dpi=300)
