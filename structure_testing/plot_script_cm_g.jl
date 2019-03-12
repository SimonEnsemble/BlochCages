using JLD2
using CSV
using DataFrames
using PyPlot
using Printf

# Pass in the following command line arguments for this plotting script to work
# 1. the name of the .jld2 file to open for plotting
# 2. the name of the csv experimental data
# 3. the name of the structure being used
# 4. the name of the .png file the plot will be saved as

structures = ARGS[1:2] # the two jld2 files to use for plotting

for input_file in structures
    # Pass the jld2 file as the first CLA
    @load input_file results density
    mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]

    # Converted mmol/g -> cm^3 STP/cm^3
    # (mmol) * (22.4 L STP) * (1000 cm^3) = (22.4) (cm^3 STP)
    # ( g  )   (1000 mmol )   (    L    )          (    g   )

    vstpg = mmolg .* (22.4)
    pressures = [results[i]["pressure (bar)"] for i = 1:length(results)]

    experimental_data_file = ""
    latex_structure_name = ""
    simulated_color = :orange
    exp_color = ""
    @printf("Crystal: %s\n", results[1]["crystal"])
    if split(results[1]["crystal"], "_")[1] == "Co24"
        @printf("Found: Co24 using: %s\n", input_file)
        experimental_data_file = "co_exp_data_cmg.csv"
        latex_structure_name = L"Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$"
        exp_color = "#F090A0"
    elseif split(results[1]["crystal"], "_")[1] == "Mo24"
        @printf("Found: Mo24 using: %s\n", input_file)
        experimental_data_file = "mo_exp_data_cmg.csv"
        latex_structure_name = L"Mo$_{24}$($^{t}$Bu-bdc)$_{24}$"
        exp_color = "#54B5B5"
    else
        @printf("No match for structure: %s\n", results[1]["crystal"])
        continue
    end

    exp_data_df = CSV.File(experimental_data_file) |> DataFrame # use standard cmg experimental data file, this won't change

    grid(true, linestyle="--", zorder=0) # the grid will be present
    #set_axisbelow(true)
    plot(pressures, vstpg, label="Simulation (298K)", color=simulated_color, marker="o", zorder=1000) # simulated data
    scatter(exp_data_df[Symbol("P(bar)")], exp_data_df[Symbol("cm3/g")], label="Experiment (298K)", color=exp_color, marker="^", zorder=1000)
    xlabel("Pressure (bar)")
    ylabel(L"Methane Adsorbed (cm$^3$ STP/g)") 
    title("Adsorption Isotherm for " * latex_structure_name) # plot is labelled based on structure name
    legend(loc=4) # legend will display in the lower right

    # Pass the output file as the second CLA
    output_file = split(input_file, ".")[1] * ".png"
    @printf("Saving figure to: %s\n", output_file)
    savefig(output_file, dpi=300)
    clf()
end
