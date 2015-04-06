#!/usr/bin/perl -w

#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: getMet.pl
#
# !DESCRIPTION:  Extracts the met source from the input.geos file
#  and passes the result to the root-level Makefile.
#\\
#\\
# !REMARKS:
#  Designed for use with the Unit Test makefiles after copying a run directory.
# 
# !REVISION HISTORY: 
#  12 Mar 2015 - E. Lundgren - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#

# Scalars
my $rundir  = "";
my $line    = "";
my $met  = "";

# Arrays
my @linestrings = ();
my @rundirstrings = ();

# Grep for input.geos header
$line       = qx( grep "GEOS-CHEM UNIT TEST SIMULATION" ./input.geos );
chomp( $line );

# Split by spaces
@linestrings    = split( ' ', $line );

# Extract the original run directory name
$rundir          = "$linestrings[4]";

# Split by _
@rundirstrings  = split( '_', $rundir );

# Place in runinfo
$met         = "$rundirstrings[0]";

# Print the result so that the Makefile can grab it
print "$met";

# Return normally
exit(0);
#EOC
