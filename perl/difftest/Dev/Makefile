#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile (in the Dev subdirectory)
#
# !DESCRIPTION: This makefile compiles and runs the development version
#  of GEOS-Chem (aka "Dev") as part of a difference test.
#\\
#\\
# !REMARKS:
# To build the programs, call "make" with the following syntax:
#                                                                             .
#   make TARGET [ OPTIONAL-FLAGS ]
#                                                                             .
# To display a complete list of options, type "make help".
#                                                                             .
#
# !REVISION HISTORY:
#  Navigate to your unit tester directory and type 'gitk' at the prompt
#  to browse the revision history.
#EOP
#------------------------------------------------------------------------------
#BOC

###############################################################################
###                                                                         ###
###  Initialization section                                                 ###
###                                                                         ###
###############################################################################

# Use GNU bash shell
SHELL   :=/bin/bash

###############################################################################
###                                                                         ###
###  Makefile targets section                                               ###
###                                                                         ###
###############################################################################

.PHONY: all clean realclean

all: dev

dev:
	rm -f $(LOG)
	@$(MAKE) lib
	@$(MAKE) run

lib:
	@$(MAKE) -C $(CODE) >> $(LOG)
	cp -f $(CODE)/bin/geos $(EXEC)

run:
	./$(EXEC) >> $(LOG)
	@$(MAKE) addsuffixdev

addsuffixdev:
	@for f in ./$(TRAC_RST); do                                 \
           if [[ -f $$f ]]; then mv -f $$f $$f.Dev; fi;             \
        done
	@for f in ./trac_avg*; do                                   \
           if [[ -f $$f ]]; then mv -f $$f $$f.Dev; fi;             \
        done
	@for f in ./HEMCO_restart*.nc; do                           \
           if [[ "$$f" != "./HEMCO_restart.$(STARTDATE)0000.nc" ]]; \
              then mv -f $$f $$f.Dev; fi;                           \
        done
	@for f in ./HEMCO_diagnostics*.nc; do                       \
           if [[ -f $$f ]]; then mv -f $$f $$f.Dev; fi;             \
        done
	@for f in ./HEMCO.log; do                                   \
           if [[ -f $$f ]]; then mv -f $$f $$f.Dev; fi;             \
        done
	@for f in ./GEOSChem*.nc4; do                               \
           if [[ -f $$f ]]; then mv -f $$f $$f.Dev; fi;             \
        done

clean:
	@$(MAKE) -C $(CODE) clean

realclean:
	@$(MAKE) -C $(CODE) realclean
	rm -f $(EXEC)

tvsp:
	@$(MAKE) -C $(CODE)
	cp -f $(CODE)/bin/geos $(EXEC)
	totalview $(EXEC) &

tvmp:
	@$(MAKE) -C $(CODE)
	cp -f $(CODE)/bin/geos $(EXEC)
	totalview $(EXEC) &

#EOC
