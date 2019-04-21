using JLD2
using CSV
using DataFrames
using PyPlot
using Printf

# Converted mmol/g -> cm^3 STP/g
# (mmol) * (22.4 L STP) * (1000 cm^3) = (22.4) (cm^3 STP)
# ( g  )   (1000 mmol )   (    L    )          (    g   )

# Converted cm^3/g -> cm^3 STP/cm^3
# (cm^3 STP) * (ρ kg) * (   (m)^3  ) * (1000g) = (ρ cm^3 STP)
# (   g    )   ( m^3)   ((100 cm)^3)   (  kg )   (1000  cm^3)

co_latex_name = L"Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$"
mo_latex_name = L"Mo$_{24}$($^{t}$Bu-bdc)$_{24}$"

plot_heat = false
overlap_heat = !plot_heat

data_files = ["Co24_P1_cleaned_missingCo_added_Dreiding_100Kcycles.jld2", "Mo24_P1_Dreiding_100Kcycles.jld2"]

for input_file in data_files

    # Pass the jld2 file as the first CLA
    @load input_file results density

    @assert(results[1]["forcefield"] == "Dreiding_UFF_for_Co_and_Mo.csv")
    @assert(results[1]["adsorbate"] == :CH4)

    mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]
    cm3stpcm3 = mmolg * 22.4 * density / 1000

    simulated_color = :orange
    @printf("Crystal: %s\n", results[1]["crystal"])
    if split(results[1]["crystal"], "_")[1] == "Co24"
        @printf("Found: Co24 using: %s\n", input_file)
        experimental_data_file_cmg = "co_exp_data_cmg.csv"
        experimental_data_file_qst = "co_exp_data_qst.csv"
        latex_structure_name = co_latex_name
        exp_color = "#F090A0"
        marker = "o"
    elseif split(results[1]["crystal"], "_")[1] == "Mo24"
        @printf("Found: Mo24 using: %s\n", input_file)
        experimental_data_file_cmg = "mo_exp_data_cmg.csv"
        experimental_data_file_qst = "mo_exp_data_qst.csv"
        latex_structure_name = mo_latex_name
        exp_color = "#54B5B5"
        marker = "D"
    else
        @printf("No match or experimental data for structure: %s\n", results[1]["crystal"])
        continue
    end

    if overlap_heat
        simulated_color = exp_color
    end

    heat_data_df = CSV.File(experimental_data_file_qst) |> DataFrame # use the heat data .csv file
    heat_data_df[Symbol("cm3/cm3")] = heat_data_df[Symbol("(mmol/g)")] * 22.4 * density / 1000 # using unit conversions defined above

    # plotting the energy of adsorption
    qst_k = [results[i]["Q_st (K)"] for i = 1:length(results)]
    qst_kjmol = qst_k * 8.314 / 1000

    last_index = 1;

    while cm3stpcm3[last_index] < heat_data_df[Symbol("cm3/cm3")][end]
        last_index += 1
    end

    cm3stpcm3_short = cm3stpcm3[1:last_index]
    qst_kjmol_short = qst_kjmol[1:last_index]

    grid(true, linestyle="--", zorder=0) # the grid will be present
    # plot simulation
    plot(cm3stpcm3_short, qst_kjmol_short, label= latex_structure_name * " Simulation (298 K)", color=simulated_color, marker=marker, mfc="none", zorder=1000, clip_on=false)
    # plot experimental
    scatter(heat_data_df[Symbol("cm3/cm3")], heat_data_df[Symbol("Qst(kJ/mol)")], label= latex_structure_name * " Experiment (298K)", color=exp_color, marker=marker, zorder=1000, clip_on=false)
    if plot_heat
        xlabel(L"Methane Adsorbed (cm$^3$ STP/cm$^3$)")
        ylabel(L"Q$_{st}$ (kJ/mol)")
        ylim([0, 22])
        title("Heat of Adsorption for " * latex_structure_name)
        legend(loc=4) # legend will display in the lower right

        output_file_heat = joinpath(pwd(), "plots", split(input_file, ".")[1] * "_heat.png")
        savefig(output_file_heat, dpi=300)
        clf()
    end
end

if overlap_heat
    xlabel(L"Methane Adsorbed (cm$^3$ STP/cm$^3$)")
    ylabel(L"Q$_{st}$ (kJ/mol)")
    ylim([0, 22])

    title("Heat Adsorption for " * co_latex_name * " and " * mo_latex_name)
    legend(loc=4) # legend will display in the lower right

    # TODO find a concise, descriptive name for this figure so it is clear where the data is coming from
    output_file_both = joinpath(pwd(), "plots", "qst_plot_both_structures.png")
    @printf("Saving figure to: %s\n", output_file_both)
    savefig(output_file_both, dpi=300)
    clf()
end
