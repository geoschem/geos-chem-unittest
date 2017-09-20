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
	if [[ -f $(TRAC_AVG) ]]; then mv -f $(TRAC_AVG) $(TRAC_AVG).Dev; fi;
	if [[ -f $(TRAC_RST) ]]; then mv -f $(TRAC_RST) $(TRAC_RST).Dev; fi;
	if [[ -f $(HIST_INS) ]]; then mv -f $(HIST_INS) $(HIST_INS).Dev; fi;
	if [[ -f $(HMCO_AVG) ]]; then mv -f $(HMCO_AVG) $(HMCO_AVG).Dev; fi;
	if [[ -f $(HMCO_RST) ]]; then mv -f $(HMCO_RST) $(HMCO_RST).Dev; fi;
	if [[ -f $(HMCO_LOG) ]]; then mv -f $(HMCO_LOG) $(HMCO_LOG).Dev; fi;

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
