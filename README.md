# BlochCages

The `script_template.sh` and `simulation_template.jl` can be copied into testing folders to run computations on the hpc. The `simulation_template.jl` file is modular and is run by using command line arguments, so to modifiy these files for different testing edit the `script_template.sh` by replacing `<VARIABLE>` with the correct file name.

# Structure of repository
```
.
├── ...
├── Dreiding_UFF_for_Co_and_Mo.csv              # Forcefield file that combines Dreiding and UFF used to achieve most accurate simulation data
├── methane_data.xlsx                           # Exel spreadsheet containing experimental data for the Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$ and Mo$_{24}$($^{t}$Bu-bdc)$_{24}$
├── simulations                                 # Folder containing all simulation files and output data
│   ├── mo_co_uff_dreiding.jl                   # Julia script for calculating adsorption isotherms for Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$ and Mo$_{24}$($^{t}$Bu-bdc)$_{24}$ with the adsorbate CH$_{4}$
│   │                                           #   using the UFF and Dreiding_UFF forcefields for pressure on a logarithmic scale from 0.01 bar to 65 bar. This outputs .jld2 files of the
│   │                                           #   format: <structure name>_<forcefield>_100Kcycles.jld2
│   ├── structure_script.sh                     # Shell script for running the mo_co_uff_dreiding.jl file with multiple cores to use parallel processing on OSU's computing cluster
│   ├── density_grid_pressure_range.jl          # Julia script for calculating the density grid for Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$ and Mo$_{24}$($^{t}$Bu-bdc)$_{24}$ with the adsorbate CH$_{4}$
│   │                                           #   using the Dreiding_UFF forcefield file for the pressures: 1 bar, 5 bar, 35 bar, and 65 bar. This outputs .jld2 files of the format
│   │                                           #   <structure_name>_<forcefield_name>_200Kcycles_grid_range.jld2
│   ├── density_grid_script.sh                  # Shell script for running the density_grid_pressure_range.jl file with multiple cores to use parallel processing on OSU's computing cluster
│   ├── snapshots_grid_simulation.jl            # Julia script for recording adsorbate positions during a GCMC simulation for Co$_{24}$(Mebdc)$_{24}$(dabco)$_{6}$ and Mo$_{24}$($^{t}$Bu-bdc)$_{24}$
│   │                                           #   with the adsorbate CH$_{4}$ using the Dreiding_UFF forcefield file at 5.0 bar. This outputs .jld2 files of the format
│   │                                           #   <structure_name>_<forcefield_name>_100Kcycles_snapshots_grid.jld2
│   ├── plot_script_cm_g.jl             
│   ├── data
│   ├── plots
│   └── viz
├── structures
│   ├──  
│   └──
```
