using JLD2
using CSV
using DataFrames
using PyPlot
using Printf

plot_cmg = false
overlap_cmg = !plot_cmg

co_latex_name = L"Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$"
mo_latex_name = L"Mo$_{24}$($^{t}$Bu-bdc)$_{24}$"

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

    if overlap_cmg
        simulated_color = exp_color
    end

    exp_data_df = CSV.File(experimental_data_file_cmg) |> DataFrame # use standard cmg experimental data file, this won't change
    exp_data_df[Symbol("cm3/cm3")] = exp_data_df[Symbol("cm3/g")] * density / 1000

    grid(true, linestyle="--", zorder=0) # the grid will be present
    #set_axisbelow(true)
    plot(pressures, cm3stpcm3, label=latex_structure_name * " Simulation (298 K)", color=simulated_color, marker=marker, zorder=1000, clip_on=false) # simulated data
    scatter(exp_data_df[Symbol("P(bar)")], exp_data_df[Symbol("cm3/cm3")], label=latex_structure_name * " Experiment (298 K)", color=exp_color, marker=marker, zorder=1000, clip_on=false)
    if plot_cmg
        xlabel("Pressure (bar)")
        ylabel(L"Methane Adsorbed (cm$^3$ STP/cm$^3$)")
        ylim([0, 250])
        xlim([0, 70])
        title("Adsorption Isotherm for " * latex_structure_name) # plot is labelled based on structure name
        legend(loc=4) # legend will display in the lower right

        output_file_adsorption = joinpath(pwd(), "plots", split(input_file, ".")[1] * ".png")
        @printf("Saving figure to: %s\n", output_file_adsorption)
        savefig(output_file_adsorption, dpi=300)
        clf()
    end

end

if overlap_cmg
    xlabel("Pressure (bar)")
    ylabel(L"Methane Adsorbed (cm$^3$ STP/cm$^3$)")
    ylim([0, 250])
    xlim([0, 70])
    title("Adsorption Isotherm for " * co_latex_name * " and " * mo_latex_name) # plot is labelled based on structure name
    legend(loc=4) # legend will display in the lower right

    # TODO find a concise, descriptive name for this figure so it is clear where the data is coming from
    output_file_both = joinpath(pwd(), "plots", "cmg_plot_both_structures.png")
    @printf("Saving figure to: %s\n", output_file_both)
    savefig(output_file_both, dpi=300)
    clf()
end
