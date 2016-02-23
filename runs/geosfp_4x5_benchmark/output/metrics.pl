#!/usr/bin/perl -w

#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: metrics.pl
#
# !DESCRIPTION: Prints out the % difference in the Mean OH concentration and 
#  the Methyl Chloroform (MCF) lifetime from two GEOS-Chem 1-month benchmark
#  simulations.
#\\
#\\
# !USES:
#
  require 5.003;                    # Need this version of Perl or newer
  use strict;                       # Force strict syntax rules

# !CALLING SEQUENCE:
#  metrics.pl v9-01-02g v9-01-02h   # Or any other two version numbers
#
# !REMARKS:
#  Assumes that both benchmark run directories are located in the same
#  root directory.  You will have to hack if you want to generalize this.
#
# !REVISION HISTORY: 
#  11 Aug 2011 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

#--------------------------------------------
# Initialization
#--------------------------------------------

# Make sure there are enough arguments
if ( scalar( @ARGV ) != 2 ) {
  print "Usage: metrics.pl VERSION1 VERSION2\n";
  exit(-1);
}

# Local arrays
my @tmp1  = ();
my @tmp2  = ();

# Local scalars
my $v1    = $ARGV[0];
my $v2    = $ARGV[1];
my $file1 = "";
my $file2 = "";
my $line1 = "";
my $line2 = "";
my $val1  = 0.0;
my $val2  = 0.0;
my $pct   = 0.0;

# Open output file
my $outFile = "$v2.metrics.fullchem";
open( O, ">$outFile") or die "Can't open $outFile\n";

#--------------------------------------------
# Print % difference in Mean OH
#--------------------------------------------

# Log files
$file1 = "../../$v1/$v1.log";
$file2 = "../$v2.log";

# Parse log files for the line w/ mean OH concentration
$line1  = qx( grep "Mean OH =" $file1 );
$line2  = qx( grep "Mean OH =" $file2 );

# Strip newlines
chomp( $line1 );
chomp( $line2 );

# Split results by spaces
@tmp1 = split( " ", $line1 );
@tmp2 = split( " ", $line2 );

# Mean OH is the 3rd substring
$val1 = $tmp1[3];
$val2 = $tmp2[3];

# Compute percent difference
$pct  = 100.0 * ( ( $val2 - $val1 ) / $val1 );

# Print results to screen
print "MEAN OH CONCENTRATION [1e5 molec/cm3/s]\n";
print '---------------------------------------'."\n";
print "$v1    : $val1\n";
print "$v2    : $val2\n";
print "% Difference : $pct\n";

# Print results to text file
print O "MEAN OH CONCENTRATION [1e5 molec/cm3/s]\n";
print O '---------------------------------------'."\n";
print O "$v1    : $val1\n";
print O "$v2    : $val2\n";
print O "% Difference : $pct\n";

#--------------------------------------------
# Print % difference in MCF lifetime
#--------------------------------------------

# Budget files
$file1 = "../../$v1/output/$v1.budget.fullchem";
$file2 = "./$v2.budget.fullchem";

# Parse budget files for the line w/ MCF lifetimes
$line1 = qx( grep 'MCF' $file1 );
$line2 = qx( grep 'MCF' $file2 );

# Strip newlines
chomp( $line1 );
chomp( $line2 );

# Split results by " "
@tmp1 = split( " ", $line1 );
@tmp2 = split( " ", $line2 );

# MCF lifetime is 4th substring 
$val1 = $tmp1[4];
$val2 = $tmp2[4];

# Compute percent difference
$pct  = 100.0 * ( ( $val2 - $val1 ) / $val1 );

# Print results to screen
print "\n";
print "MCF LIFETIME w/r/t TROP OH [years]"."\n";
print '----------------------------------'."\n";
print "$v1    : $val1\n";
print "$v2    : $val2\n";
print "% Difference : $pct\n";

# Print results to text file
print O "\n";
print O "MCF LIFETIME w/r/t TROP OH [years]"."\n";
print O '----------------------------------'."\n";
print O "$v1    : $val1\n";
print O "$v2    : $val2\n";
print O "% Difference : $pct\n";

# Close output file
close( O );

# Exit normally
exit(0);
#EOC
