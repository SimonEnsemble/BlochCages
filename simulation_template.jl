using Distributed
# this is personalized for Arthur York's OSU server space to use the development PorousMaterials
# This line can be uncommented and adjusted to use a development PorousMaterials, otherwise it will use the standard.
# @everywhere push!(LOAD_PATH, "/nfs/stak/users/yorkar/git_files/PorousMaterials.jl/src")
@everywhere using PorousMaterials
using CSV
using DataFrames
using JLD2
using Printf

# ARGS are the command line arguments passed into this script
# This file will be made modular, and the different params can be adjusted inside the specific submission script
# ARGS[1]: the crystal structure name
# ARGS[2]: forcefield name
# ARGS[3]: adsorbate name
# ARGS[4]: output file, not including the extension '.jld2'

structure = Framework(ARGS[1])
strip_numbers_from_atom_labels!(structure)
ljforcefield = LJForceField(ARGS[2])
molecule = Molecule(ARGS[3])

# fugacities will not be modified in these simulations because it runs the same range for all structures
# the fugacities will be twenty pressures from 10^-2 to 65 using a log10 scale

fugacities = 10 .^ range(-2, stop=log10(65), length=20)

results = adsorption_isotherm(structure, molecule, 298.0, fugacities, ljforcefield,
    n_burn_cycles=10000, n_sample_cycles=10000, verbose=true, show_progress_bar=false,
    eos=:PengRobinson)

output_file = ARGS[4] * ".jld2"

@save output_file results
