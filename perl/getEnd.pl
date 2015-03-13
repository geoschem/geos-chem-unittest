#!/usr/bin/perl -w

#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: getEnd.pl
#
# !DESCRIPTION:  Extracts the ending date & time from the input.geos file
#  and passes the result (in YYYYMMDDhh format) to the root-level Makefile.
#\\
#\\
# !REMARKS:
#  Designed for use with the Unit Test and Difference Test makefiles.
# 
# !REVISION HISTORY: 
#  17 Apr 2014 - R. Yantosca - Initial version
#  31 Oct 2014 - R. Yantosca - Now returns end in YYYYMMDDhhmm format
#  13 Mar 2015 - R. Yantosca - Skip if input.geos is not found
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#

# Scalars
my $end     = "";
my $line    = "";
my $start   = "";
my $hco_end = 0;

# Arrays
my @strings = ();

# Make sure that an input.geos file is found; otherwise print a "";
if ( -f "./input.geos" ) {

  # Grep for start date & time in input.geos
  $line       = qx( grep "End   YYYYMMDD" ./input.geos );
  chomp( $line );

  # Split by spaces
  @strings    = split( ' ', $line );

  # Place into YYYYMMDDhhmm format
  $end        = "$strings[4]$strings[5]";
  $end        = substr( $end, 0, 12 );
}

# Print the result so tha the Makefile can grab it
print "$end";

# Return normally
exit(0);
#EOC
