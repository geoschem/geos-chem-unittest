#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: Makefile in the runs directory.  This will execute a
#  "make fileclean" in each of the run subdirectories.
#\\
#\\
# !REMARKS:
#  This will be called by the cleanFiles script.
#  Add a line below for each additional unit-test run directory.
#
# !REVISION HISTORY: 
#  03 Sep 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# Unix shell
SHELL := /bin/bash

#=============================================================================
# Makefile targets
#=============================================================================
all:
	@$(MAKE) -C geos5_4x5_RnPbBe    fileclean
	@$(MAKE) -C geos5_4x5_fullchem  fileclean
	@$(MAKE) -C geosfp_4x5_fullchem fileclean
	@$(MAKE) -C merra_4x5_fullchem  fileclean

#EOC

