using Distributed
@everywhere using PorousMaterials
using CSV
using DataFrames
using JLD2
using Printf

forcefield_files = ["UFF.csv", "Dreiding_UFF_for_Co_and_Mo.csv"]
structure_files = ["Co24_P1_cleaned_missingCo_added.cif", "Mo24_P1.cif"]

for forcefield_name in forcefield_files
    for structure_name in structure_files

        structure = Framework(structure_name)
        strip_numbers_from_atom_labels!(structure)
        ljforcefield = LJForceField(forcefield_name)
        molecule = Molecule("CH4")

        density = crystal_density(structure)

        output_file = split(structure_name, ".")[1] * "_" * split(split(forcefield_name, ".")[1], "_")[1] * "_100Kcycles" * ".jld2"

        # fugacities will not be modified in these simulations because it runs the same range for all structures
        # the pressures will be twenty pressures from 10^-2 to 65 using a log10 scale

        pressures = 10 .^ range(-2, stop=log10(65), length=20)

        results = adsorption_isotherm(structure, molecule, 298.0, pressures,
                ljforcefield, n_burn_cycles=100000, n_sample_cycles=100000,
                verbose=true, show_progress_bar=false, eos=:PengRobinson)

        @save output_file results density

    end
end
