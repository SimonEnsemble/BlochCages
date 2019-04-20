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

plot_heat = true
overlap_heat = !plot_heat

data_files = ["Co24_P1_cleaned_missingCo_added_Dreiding_100Kcycles.jld2", "Mo24_P1_Dreiding_100Kcycles.jld2"]

if plot_heat
    for input_file in data_files

        # Pass the jld2 file as the first CLA
        @load input_file results density

        @assert(results[1]["forcefield"] == "Dreiding_UFF_for_Co_and_Mo.csv")
        @assert(results[1]["adsorbate"] == :CH4)

        mmolg = [results[i]["⟨N⟩ (mmol/g)"] for i = 1:length(results)]

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
        plot(cm3stpcm3_short, qst_kjmol_short, label="Simulation (298 K)", color=simulated_color, marker="o", zorder=1000, clip_on=false)
        scatter(heat_data_df[Symbol("cm3/cm3")], heat_data_df[Symbol("Qst(kJ/mol)")], label="Experiment (298K)", color=exp_color, marker="^", zorder=1000, clip_on=false)
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
