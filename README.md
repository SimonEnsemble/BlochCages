# BlochCages

The two crystal structures used for these simulations were:

- `./simulations/data/crystals/Co24_P1_cleaned_missingCo_added.cif` for Co<sub>24</sub>(Mebdc)<sub>24</sub>(dabco)<sub>6</sub>
- `./simulations/data/crystals/Mo24_P1.cif` for Mo<sub>24</sub>(<sup>t</sup>Bu-bdc)<sub>24</sub>

# Structure of repository
<pre>
.
├── ...
├── Dreiding_UFF_for_Co_and_Mo.csv              # Forcefield file that combines Dreiding and UFF used to achieve most accurate simulation data
├── methane_data.xlsx                           # Exel spreadsheet containing experimental data for the for Co_24(Mebdc)_24(dabco)_6 and Mo_24(tBu-bdc)_24
├── simulations                                 # Folder containing all simulation files and output data
│   ├── mo_co_uff_dreiding.jl                   # Julia script for calculating adsorption isotherms for Co_24(Mebdc)_24(dabco)_6 and Mo_24(tBu-bdc)_24 with the adsorbate CH_4
│   │                                           #   using the UFF and Dreiding_UFF forcefields for pressure on a logarithmic scale from 0.01 bar to 65 bar. This outputs .jld2 files of the
│   │                                           #   format: <structure name>_<forcefield>_100Kcycles.jld2
│   ├── structure_script.sh                     # Shell script for running the mo_co_uff_dreiding.jl file with multiple cores to use parallel processing on OSU's computing cluster
│   ├── density_grid_pressure_range.jl          # Julia script for calculating the density grid for Co_24(Mebdc)_24(dabco)_6 and Mo_24(tBu-bdc)_24 with the adsorbate CH_4
│   │                                           #   using the Dreiding_UFF forcefield file for the pressures: 1 bar, 5 bar, 35 bar, and 65 bar. This outputs .jld2 files of the format
│   │                                           #   <structure_name>_<forcefield_name>_200Kcycles_grid_range.jld2
│   ├── density_grid_script.sh                  # Shell script for running the density_grid_pressure_range.jl file with multiple cores to use parallel processing on OSU's computing cluster
│   ├── snapshots_grid_simulation.jl            # Julia script for recording adsorbate positions during a GCMC simulation for Co_24(Mebdc)_24(dabco)_6 and Mo_24(tBu-bdc)_24
│   │                                           #   with the adsorbate CH_4 using the Dreiding_UFF forcefield file at 5.0 bar. This outputs .jld2 files of the format
│   │                                           #   <structure_name>_<forcefield_name>_100Kcycles_snapshots_grid.jld2
│   ├── plot_script_cm_g.jl                     # Julia script that loads in the outputs from the mo_co_uff_dreiding.jl script and makes data visualizations to compare adsorption isotherms
│   │                                           #   and heat of adsorption between the simulated data and experimental data
│   ├── write_grid.jl                           # Julia script for
│   ├── data                                    # Simulation input files for <a href="https://github.com/SimonEnsemble/PorousMaterials.jl" title="PorousMaterials.jl">PorousMaterials.jl</a>
│   ├── plots
│   └── viz
├── structures
│   ├──  
│   └──
</pre>
