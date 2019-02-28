using Distributed
# this is personalized for Arthur York's OSU server space to use the development PorousMaterials
# This line can be uncommented and adjusted to use a development PorousMaterials, otherwise it will use the standard.
# @everywhere push!(LOAD_PATH, "/nfs/stak/users/yorkar/git_files/PorousMaterials.jl/src")
@everywhere using PorousMaterials
using CSV
using DataFrames
using JLD2
using Printf

forcefield_files = ["UFF.csv", "Dreiding_UFF_for_Co_and_Mo.csv"]
structure_files = ["Co24_P1_fixed_eqeqcharged.cif", "Mo24_P1_eqeqcharged.cif"]

for forcefield_name in forcefield_files
    for structure_name in structure_files

        structure = Framework(structure_name)
        strip_numbers_from_atom_labels!(structure)
        ljforcefield = LJForceField(forcefield_name)
        molecule = Molecule("N2")

        density = crystal_density(structure)

        output_file = "N2_" * split(structure_name, "_")[1] * "_" * split(split(forcefield_name, ".")[1], "_")[1] * ".jld2"

        # fugacities will not be modified in these simulations because it runs the same range for all structures
        # the fugacities will be twenty pressures from 10^-2 to 65 using a log10 scale

        fugacities = 10 .^ range(-2, stop=1, length=10)

        results = adsorption_isotherm(structure, molecule, 77.0, fugacities,
                ljforcefield, n_burn_cycles=10000, n_sample_cycles=10000,
                verbose=true, show_progress_bar=false, eos=:PengRobinson)

        @save output_file results density

    end
end
