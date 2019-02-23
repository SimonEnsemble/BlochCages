using JLD2
using Plots

# Pass the jld2 file as the first CLA
input_file = ARGS[1]

@load input_file results

mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]
pressures = [results[i]["fugacity (bar)"] for i = 1:length(results)]

scatter!(pressures, mmolg, color=:black, m=:rect, dpi=300)
xaxis!("Fugacity (bar)")
yaxis!("⟨N⟩ (mmol/g)")
title!("Adsorption Isotherm for <STRUCTURE_NAME>")

# Pass the output file as the second CLA
savefig(ARGS[2])
