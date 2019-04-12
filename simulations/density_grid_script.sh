#!/bin/bash

# use current working directory for input and output
# default is to use the users home directory
#$ -cwd

# name this job
#$ -N density_grid

# send stdout and stderror to this file
#$ -o density_grid.o
#$ -e density_grid.e
#$ -j y

#the list of users who will recieve mail about this job
#$ -M yorkar@oregonstate.edu
#options for when mail is sent out, this will send mail when the job begins,
#       ends, or is aborted
#$ -m bea

# select queue - if needed; mime5 is SimonEnsemble priority queue but is restrictive.
#$ -q mime5

#set up a parallel environment
#$ -pe openmpi 4

# print date and time
date

# This will use 4 cores, to use more, change the `-p` flag
julia -p 4 density_grid_pressure_range.jl
