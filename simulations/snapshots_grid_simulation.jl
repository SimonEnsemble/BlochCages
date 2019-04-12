using PorousMaterials
using CSV
using JLD2
using DataFrames
using Printf

forcefield_files = ["Dreiding_UFF_for_Co_and_Mo.csv"]
structure_files = ["Co24_P1_cleaned_missingCo_added.cif", "Mo24_P1.cif"]

for forcefield_name in forcefield_files
    for structure_name in structure_files

        structure = Framework(structure_name)
        strip_numbers_from_atom_labels!(structure)
        ljforcefield = LJForceField(forcefield_name)
        molecule = Molecule("CH4")

        density = crystal_density(structure)

        output_file = split(structure_name, ".")[1] * "_" * split(split(forcefield_name, ".")[1], "_")[1] * "_100K_test_snapshot_changes" * ".jld2"

        results = gcmc_simulation(structure, molecule, 298.0, 5.0, ljforcefield,
                    n_burn_cycles=100000, n_sample_cycles=100000, write_adsorbate_snapshots=true,
                    snapshot_frequency=1000, calculate_density_grid=true,
                    filename_comment="snapshots_grid", verbose=true)

        @save output_file results density

    end
end
