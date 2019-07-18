#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile (in the Ref subdirectory)
#
# !DESCRIPTION: This makefile compiles and runs the reference version
#  of GEOS-Chem (aka "Ref") as part of a difference test.
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

all: ref

ref:
	rm -f $(LOG)
	@$(MAKE) lib
	@$(MAKE) run

lib:
	@$(MAKE) -C $(CODE) >> $(LOG)
	cp -f $(CODE)/bin/geos $(EXEC)

run:
	rm -f trac_avg*
	./$(EXEC) >> $(LOG)
	@$(MAKE) addsuffixref

addsuffixref:
	@for f in ./$(GC_RST); do                                  \
           if [[ -f $$f ]]; then mv -f $$f $$f.Ref; fi;            \
        done
	@for f in ./$(TRAC_AVG); do                                \
           if [[ -f $$f ]]; then mv -f $$f $$f.Ref; fi;            \
        done
	@for f in ./$(HMCO_RST); do                                \
           if [[ -f $$f ]]; then mv -f $$f $$f.Ref; fi;            \
        done
	@for f in ./OutputDir/HEMCO_diagnostics*.nc; do            \
           if [[ -f $$f ]]; then mv -f $$f $$f.Ref; fi;            \
        done
	@for f in ./HEMCO.log; do                                  \
           if [[ -f $$f ]]; then mv -f $$f $$f.Ref; fi;            \
        done
	@for f in ./OutputDir/GEOSChem*.nc4; do                    \
           if [[ -f $$f ]]; then mv -f $$f $$f.Ref; fi;            \
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
