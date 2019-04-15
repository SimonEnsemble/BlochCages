using JLD2
using CSV
using DataFrames
using PyPlot
using Printf

data_files = ["Co24_P1_cleaned_missingCo_added_Dreiding_100Kcycles.jld2", "Mo24_P1_Dreiding_100Kcycles.jld2"]

for input_file in data_files
    # Pass the jld2 file as the first CLA
    @load input_file results density

    @assert(results[1]["forcefield"] == "Dreiding_UFF_for_Co_and_Mo.csv")
    @assert(results[1]["adsorbate"] == :CH4)
    
    mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]

    # Converted mmol/g -> cm^3 STP/g
    # (mmol) * (22.4 L STP) * (1000 cm^3) = (22.4) (cm^3 STP)
    # ( g  )   (1000 mmol )   (    L    )          (    g   )

    cm3stpg = mmolg * 22.4
    pressures = [results[i]["pressure (bar)"] for i = 1:length(results)]

    # Converted cm^3/g -> cm^3 STP/cm^3
    # (cm^3 STP) * (ρ kg) * (   (m)^3  ) * (1000g) = (ρ cm^3 STP)
    # (   g    )   ( m^3)   ((100 cm)^3)   (  kg )   (1000  cm^3)

    cm3stpcm3 = cm3stpg * density / 1000

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
        @printf("No match or experimental data for structure: %s\n", results[1]["crystal"])
        continue
    end

    exp_data_df = CSV.File(experimental_data_file) |> DataFrame # use standard cmg experimental data file, this won't change
    exp_data_df[Symbol("cm3/cm3")] = exp_data_df[Symbol("cm3/g")] * density / 1000


    grid(true, linestyle="--", zorder=0) # the grid will be present
    #set_axisbelow(true)
    plot(pressures, cm3stpcm3, label="Simulation (298 K)", color=simulated_color, marker="o", zorder=1000, clip_on=false) # simulated data
    scatter(exp_data_df[Symbol("P(bar)")], exp_data_df[Symbol("cm3/cm3")], label="Experiment (298 K)", color=exp_color, marker="^", zorder=1000, clip_on=false)
    xlabel("Pressure (bar)")
    ylabel(L"Methane Adsorbed (cm$^3$ STP/cm$^3$)") 
    ylim([0, 250])
    xlim([0, 70])
    title("Adsorption Isotherm for " * latex_structure_name) # plot is labelled based on structure name
    legend(loc=4) # legend will display in the lower right

    # Pass the output file as the second CLA
    output_file_adsorption = split(input_file, ".")[1] * ".png"
    @printf("Saving figure to: %s\n", output_file_adsorption)
    savefig(output_file_adsorption, dpi=300)
    clf()
    

    # plotting the energy of adsorption
    qst_k = [results[i]["Q_st (K)"] for i = 1:length(results)]
    qst_kjmol = qst_k * 8.314 / 1000

    grid(true, linestyle="--", zorder=0) # the grid will be present
    plot(cm3stpcm3, qst_kjmol, label="Simulated (298 K)", color=simulated_color, marker="o", zorder=1000, clip_on=false)
    xlabel(L"Methane Adsorbed (cm$^3$ STP/cm$^3$)")
    ylabel(L"Q$_{st}$ kJ/mol")
    ylim([0, 17])
    title("Heat of Adsorption for " * latex_structure_name)
    legend(loc=4) # legend will display in the lower right

    output_file_heat = split(input_file, ".")[1] * "_heat.png"
    savefig(output_file_heat, dpi=300)
    clf()

end
