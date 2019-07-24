[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/geoschem/geos-chem-unittest/blob/dev/12.6.0/LICENSE.txt)

# README for the GEOS-Chem Unit Tester repository

This repository (https://github.com/gcst/geos-chem-unittest) contains GEOS-Chem Unit Tester package.

## Overview

### Description

The GEOS-Chem Unit Tester is a package of scripts and Makefiles that will compile and run several GEOS-Chem simulations with a set of standard debugging flags. The user may select the types of simulations to be tested.

You can also use the GEOS-Chem Unit Tester to generate run directories for the various types of GEOS_Chem simulations.

For more information, see our page on the GEOS-Chem wiki:

   http://wiki.geos-chem.org/GEOS-Chem Unit Tester

### Directories:

  * __jobs/__ : Job scripts created by the GEOS-Chem Unit Test driver script "gcUnitTest" will be sent here.

  * __logs/__ : Log files containing output from the GEOS-Chem Unit Test simulations will be sent here.

  * __perl/__ : Contains the Perl scripts that are used to submit GEOS-Chem Unit Test (or difference test) simulations, as well as to generate GEOS-Chem run directories).

  * __runs/__ : Contains the various run directories.  Each run directory is named according to the met field, horizontal grid, and type of simulation

### Branches
This repository contains several branches, each of which contains several code updates belonging to a particular line of development.  In particular you will see:

 * The __master__ branch always contains the Unit Tester that corresponds to the last benchmarked version of GEOS-Chem.  You should never add new code directly into this branch.  Instead, open a new branch off of master and add your code there.

 * The __Dev__ branch always contains the Unit Tester that corresponds to in-development code for the next version to be benchmarked.  Code in Dev is very much "work in progress" and should not relied upon until it has been debugged and benchmarked.


## Creating GEOS-Chem run directories

You can use the GEOS-Chem Unit Tester to create run directories for the various types of GEOS-Chem simulations.  For more information, please follow the instructions on this wiki page:

  * http://wiki.geos-chem.org/Creating_GEOS-Chem_run_directories

## Running GEOS-Chem unit tests

GEOS-Chem unit tests can be run with a a script called __gcUnitTest__.  To run the gcUnitTest script, you first specify the options for the unit test simulations in an input file.  You can specify the directory paths for your system, the location of the GEOS-Chem code directory, the submit command for your system, and the types of simulations that you want the Unit Tester to validate.  The default input file is named UnitTest.input, but you can copy and cut-n-paste to create as many input files as you need.  

To start the unit test simulation, cd into the perl subdirectory and type:

  gcUnitTest FILENAME

where FILENAME is the name of input file (e.g. UnitTest.input).  This will start the Unit Test simulations.  Normally this will run in a queue on your computational cluster.  If no FILENAME is given, gcUnitTest will read the default file "UnitTest.input".

The GEOS-Chem Unit Tester will compile and run the code for each of the types of simulations that you specified in the input file.  The Unit Tester will compile and run GEOS-Chem twice for each type of simulation (once with OpenMP parallelizaton turned off, and again with OpenMP parallelization turned on).  Then the Unit tester will check to see if the output files from both simulations are identical.

Output from each simulation is sent to the logs/ subdirectory.  A new subdirectory can be created for each individual unit test.  The stdout from the Unit Test simulation is sent to the log file {VERSION}.stdout.log, where {VERSION} is an ID tag used to identify the simulation.  The log files from each individual Unit Test simulation is also sent to the logs/ subdirectory.  The stderr output is sent to a file whose name is determined by the queue system, also in logs/.

To clean all of the files created by the unit tester (job scripts, logs, bpch files), change to the perl/ directory and type

    cleanFiles

## Running GEOS-Chem difference tests

A difference test validates two versions of GEOS-Chem. It compares model output from a version of GEOS-Chem in which you have made updates (aka the development code, or "Dev") against a version of GEOS-Chem with known behavior (aka the reference code, or "Ref").

For detailed instructions on how to run GEOS-Chem difference tests, please see our wiki page 

  * http://wiki.geos-chem.org/Performing_Difference_Tests_with_GEOS-Chem

## Support 
We encourage GEOS-Chem users to use the Github issue tracker attached to this repository to report  bugs or technical issues with the GEOS-Chem code.

You are also invited to direct GEOS-Chem support requests to the GEOS-Chem Support Team at geos-chem-support@as.harvard.edu.

## License

GEOS-Chem and Related Software (such as this Unit Tester) are distributed
under the MIT license.  Please read the license documents LICENSE.txt and
AUTHORS.txt, both of which are located in the root folder.


----

21 Jun 2018 | GEOS-Chem Support Team | geos-chem-support@as.harvard.edu
