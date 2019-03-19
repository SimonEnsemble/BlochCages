using PorousMaterials, JLD2, Printf

xtals = Dict("Co" => "Co24_P1_cleaned_missingCo_added.cif", 
             "Mo" => "Mo24_P1.cif")

ljff = LJForceField("Dreiding_UFF_for_Co_and_Mo.csv")
molecule = Molecule("CH4")

for metal in ["Co", "Mo"]
    framework = Framework(xtals[metal])
    strip_numbers_from_atom_labels!(framework)

    write_vtk(framework.box, metal)
    write_xyz(framework, metal * ".xyz")

    n_pts = required_n_pts(framework.box, 0.25)
    grid = energy_grid(framework, molecule, ljff, n_pts=n_pts)
    write_cube(grid, metal * "_energy_grid.cube")
end

# load in arthur's spatial prob. density grids
density_grid_jlds = Dict("Co" => "Co24_P1_cleaned_missingCo_added_Dreiding_200Kcycles_grid_range.jld2",
                         "Mo" => "Mo24_P1_Dreiding_200Kcycles_grid_range.jld2")

pressures = [1.0, 5.0, 35.0, 65.0]

for metal in ["Co", "Mo"]
    printstyled(metal * ":\n"; color=:yellow)

    @load density_grid_jlds[metal] results
    for (i_p, res) in enumerate(results)
        @assert isapprox(res["pressure (bar)"], pressures[i_p])
        @assert res["forcefield"] == ljff.name
        @assert res["adsorbate"] == molecule.species
        
        density_grid = res["density grid"]
        @printf("\t⟨N⟩(%.1f bar)=%.3f, sum of grid = %.3f\n",
            pressures[i_p], res["⟨N⟩ (molecules)"], 
            sum(density_grid.data))

        write_cube(density_grid, @sprintf("%s_%.1fbar_density_grid.cube",
            metal, pressures[i_p]))
    end
end
