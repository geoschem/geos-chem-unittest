#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile (in doc subdirectory)
#
# !DESCRIPTION: Makefile for building the documentation for the
#  GEOS-Chem-UnitTest package.  Reference manuals will be created in both
#  PDF and PS formats.
#\\
#\\
# !REMARKS:
# To build the documentation, call "make" with the following syntax:
#                                                                             .
#   make doc
#                                                                             .
# You must have the LaTeX utilities (latex, dvips, dvipdf) installed
# on your system in order to build the documentation.
#
# !REVISION HISTORY: 

#  29 Aug 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

#==============================================================================
# Initialization
#==============================================================================

SHELL :=/bin/bash

# List of source code files (order is important)
SRC   :=                \
intro.ut                \
../perl/gcUnitTest      \
../perl/UnitTest.input  \
../perl/Dates.pm        \
../perl/UtUtils.pm	\
../perl/cleanFiles	\
../perl/validate


# Output file names
TEX   :=GEOS-Chem-UnitTest.tex
DVI   :=GEOS-Chem-UnitTest.dvi
PDF   :=GEOS-Chem-UnitTest.pdf
PS    :=GEOS-Chem-UnitTest.ps

#==============================================================================
# Makefile targets
#==============================================================================

.PHONY: all doc docclean help

all: doc

doc:
	rm -f $(TEX)
	protex -sfS $(SRC) > $(TEX)
	latex $(TEX)
	latex $(TEX)
	latex $(TEX)
	dvipdf $(DVI) $(PDF)
	dvips $(DVI) -o $(PS)
	rm -f *.aux *.dvi *.log *.toc

clean:
	rm -f *.tex *.ps *.pdf
#EOC
