using PorousMaterials
using JLD2
using CSV
using DataFrames
using Printf

structure_files = ["Co24_P1_cleaned_missingCo_added.cif", "Mo24_P1.cif"]
forcefield_files = ["Dreiding_UFF_for_Co_and_Mo.csv"]

for structure_name in structure_files
    for forcefield_name in forcefield_files

        structure = Framework(structure_name)
        strip_numbers_from_atom_labels!(structure)
        ljforcefield = LJForceField(forcefield_name)
        molecule = Molecule("CH4")

        output_file = split(structure_name, ".")[1] * "_" * split(split(forcefield_name, ".")[1], "_")[1] * "_200Kcycles_grid_range" * ".jld2"

        pressures = [1.0, 5.0, 35.0, 65.0]

        results = adsorption_isotherm(structure, molecule, 298.0, pressures,
                    ljforcefield, n_burn_cycles=100000, n_sample_cycles=200000,
                    eos=:PengRobinson, snapshot_frequency=1, calculate_density_grid=true,
                    density_grid_dx=0.5, filename_comment="grid_range")

        @save output_file results

    end
end
