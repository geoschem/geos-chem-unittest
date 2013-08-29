#!/usr/bin/perl -w

#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: UtUtils.pm
#
# !DESCRIPTION: Contains utility functions that are used by the 
#  GEOS-Chem Unit Tester package.
#\\
#\\
# !INTERFACE:
#
package UtUtils;
#
# !USES:
#
require 5.003;      # need this version of Perl or newer
use English;        # Use English language
use strict;         # Force explicit variable declarations (like IMPLICIT NONE)
#
# !PUBLIC MEMBER FUNCTIONS:
#  &baseName      : Returns a directory name minus the full path
#  &checkDir      : Ensures that a directory exists
#  &cleanDir      : Removes files from a directory
#  &fmtStr        : Pads a date string w/ leading zeroes if necessary
#  &makeInputGeos : Creates a new input.geos file for each day of simulation
#  &parse         : Parses a line separated by ":" and returns the 2nd value
#  &replaceDate   : Replaces YYYY, MM, DD tokens in a string w/ date values
#
# !CALLING SEQUENCE:
#  use UtUtils qw( function-name1, function-name2, ... );
#
# !REVISION HISTORY:
#  20 Jun 2013 - R. Yantosca - Initial version, moved other routines here
#  30 Jul 2013 - R. Yantosca - Added function &checkDir
#  28 Aug 2013 - R. Yantosca - Added functions &cleanDir, $baseName
#EOP
#------------------------------------------------------------------------------
#BOC

BEGIN {

  #=========================================================================
  # The BEGIN method lists the names to export to the calling routine
  #=========================================================================
  use Exporter ();
  use vars     qw( $VERSION @ISA @EXPORT_OK );

  $VERSION   = 1.00;                                   # version number
  @ISA       = qw( Exporter       );                   # export method
  @EXPORT_OK = qw( &baseName
                   &checkDir
                   &cleanDir
                   &fmtStr        
                   &makeInputGeos
                   &parse
                   &replaceDate   );                   # export on request
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: baseName
#
# !DESCRIPTION: Returns the last part of a full path name.  Similar to the
#  GNU Make "notdir" function.
#\\
#\\
# !INTERFACE:
#
sub baseName($) { 
#
# !INPUT PARAMETERS:
#
  my ( $dir )  =  @_;   # String to be parsed
#
# !RETURN VALUE:
#
  my $baseName = "";    # Directory name minus the full path
#
# !CALLING SEQUENCE:
#  &baseName( $dir );
#
# !REVISION HISTORY:
#  30 Jul 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

  # Take the text following the colon
  my @result = split( '/', $dir );
  
  # Return the last part of the directory
  $baseName = $result[ scalar( @result ) - 1 ];

  # Return to calling routine
  return( $baseName );
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: checkDir
#
# !DESCRIPTION: Checks to make sure a directory exists.  If not, then it
#  will exit with an error code.
#\\
#\\
# !INTERFACE:
#
sub checkDir($) { 
#
# !INPUT PARAMETERS:
#
  my ( $dir ) =  @_;   # Directory to be tested
#
# !CALLING SEQUENCE:
#  &checkDir( $dir );
#
# !REVISION HISTORY:
#  30 Jul 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

  # Halt execution if directory is not found
  if ( !( -d $dir ) ) {    
    print "Directory $dir does not exist!  Exiting.\n";
    exit(999)
  }
  
  # Otherwise return w/ error status
  return( $? );
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: cleanDir
#
# !DESCRIPTION: Removes files from a directory.
#\\
#\\
# !INTERFACE:
#
sub cleanDir($) {
#
# !INPUT PARAMETERS:
#
  my ( $dir ) = @_;   # Directory to be cleaned
#
# !CALLING SEQUENCE:
#  &cleanDir( $dir );
#
# !REVISION HISTORY:
#  26 Aug 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # Scalars
  my $cmd   = "";
  my $file  = "";
  
  # Arrays
  my @files = ();

  # Read all log files in the directory
  opendir( D, "$dir" ) or die "$$dir is an invalid directory!\n";
  chomp( @files = readdir( D ) );
  closedir( D );

  # Remove log files only
  foreach $file ( @files ) {
    if ( !( $file =~ m/^\./ ) ) {
      $cmd = "rm -f $dir/$file";
      print "$cmd\n";
      qx( $cmd );
    }
  }	
}
#EOP
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: fmtStr
#
# !DESCRIPTION: Returns a date/time string in either YYYYMMDD or HHMMSS format.
#  The string is padded with leading zeroes if necessary.
#\\
#\\
# !INTERFACE:
#
sub fmtStr($) {
#
# !INPUT PARAMETERS:
#
  my ( $num ) = @_;   # Value to pad (if necessary)
#
# !RETURN VALUE:
#
  my $str     = "";   # Modified string
#
# !CALLING SEQUENCE:
#  $dateStr = &fmtStr( 20040101 );
#  $dateStr = &fmtStr( 0        );
# 
# !REMARKS:
#  Used by routine &makeInputGeos below.
#
# !REVISION HISTORY:
#  23 May 2013 - R. Yantosca - Initial version, based on NRT-ARCTAS
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  my $tmp = int( $num );

  # Pad w/ proper # of leading zeroes (if necessary)
  if    ( $tmp == 0                      ) { $str = "000000";    }
  elsif ( $tmp >= 100   && $tmp < 1000   ) { $str = "000$tmp";   }
  elsif ( $tmp >= 1000  && $tmp < 10000  ) { $str = "00$tmp";    }
  elsif ( $tmp >= 10000 && $tmp < 100000 ) { $str = "0$tmp";     }
  else                                     { $str = "$tmp";      }

  # Return to calling program
  return( $str );
}
#EOP
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: makeInputGeos
#
# !DESCRIPTION: Constructs the "input.geos" file for GEOS-Chem.  It reads a 
#  pre-defined template file and then just replaces tokens with the values
#  passed via the argument list.
#\\
#\\
# !INTERFACE:
#
sub makeInputGeos($$$$$$) {
#
# !INPUT PARAMETERS:
#
  # $date1    : Starting date for GEOS-Chem model run (e.g. 20040101) 
  # $time1    : Starting time for GEOS-Chem model run (e.g. 000000  ) 
  # $date2    : Ending   date for GEOS-Chem model run (e.g. 20040102)
  # $time2    : Ending   time for GEOS-Chem model run (e.g. 000000  ) 
  # $dataRoot : GEOS-chem root data directory
  # $template : Path for input.geos "template" file
  # $fileName : Path for input.geos file (w/ dates replaced)
  my ( $date1, $time1, $date2, $time2, $dataRoot, $inFile, $outFile ) = @_;
#
# !CALLING SEQUENCE:
# &makeInputGeos( 20130101,             000000, 
#                 20130102,             000000, 
#                 "/as/data/geos/",
#                "input.geos.template", "input.geos" );
#
# !REVISION HISTORY:
#  23 May 2013 - R. Yantosca - Initial version, adapted from NRT-ARCTAS
#  31 Jul 2013 - R. Yantosca - Change permission of input.geos to chmod 777
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  my @lines  = "";
  my $line   = "";
  my $dStr1  = &fmtStr( $date1 );
  my $dStr2  = &fmtStr( $date2 );
  my $tStr1  = &fmtStr( $time1 );
  my $tStr2  = &fmtStr( $time2 );

  #------------------------------  
  # Read template file
  #------------------------------ 

  # Read template "input.geos" file into an array
  open( I, "$inFile" ) or croak( "Cannot open $inFile!\n" );
  @lines = <I>;
  close( I );

  #------------------------------  
  # Create "input.geos" file
  #------------------------------ 

  # Open file
  open( O, ">$outFile") or die "Can't open $outFile\n";

  # Loop thru each line
  foreach $line ( @lines ) {
    
    # Remove newline character
    chomp( $line );

    # Replace start & end dates
    $line =~ s/{DATE1}/$dStr1/g;
    $line =~ s/{TIME1}/$tStr1/g;
    $line =~ s/{DATE2}/$dStr2/g; 
    $line =~ s/{TIME2}/$tStr2/g;
    $line =~ s/{DATA_ROOT}/$dataRoot/g;

    # Write to output file
    print O "$line\n";
  }

  # Close output file
  close( O );

  # Make the input.geos file chmod 644
  chmod( 0644, $outFile );

  # Exit
  return(0);
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: parse
#
# !DESCRIPTION: Convenience routine for gcUnitTest.  Parses a line with
#  two substrings separated by a colon, and returns second value.
#\\
#\\
# !INTERFACE:
#
sub parse($) { 
#
# !INPUT PARAMETERS:
#
  # $str      : String to be parsed
  my ( $str ) =  @_;
#
# !CALLING SEQUENCE:
#  &checkDir( $dir );
#
# !REVISION HISTORY:
#  30 Jul 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

  # Take the text following the colon
  my @result = split( ':', $str );
  
  # Strip leading spaces
  $result[1] =~ s/^\s+//; 

  # Strip trailing spaces
  $result[1] =~ s/^\s+$//;

  # Return to calling routine
  return( $result[1] );
}
#EOP
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: replaceDate
#
# !DESCRIPTION: Routine replaceDate replaces date tokens (YYYY, MM, DD) in
#  a string with the actual year, month, and date values.
#\\
#\\
# !INTERFACE:
#
sub replaceDate($$) {
#
# !INPUT PARAMETERS:
#
  my ( $str, $date ) = @_;  # $str: String w/ tokens; 
                            # $date: YYYYMMDD date
#
# !RETURN VALUE:
#
  my $newStr = "";          # Updated string 
#
# !CALLING SEQUENCE:
#  $newStr = &replaceDate( "file.YYYYMMDD", 20130101 );
#
# !REVISION HISTORY:
#  23 May 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  my $yyyy = substr( $date, 0, 4 );    # Extract year  from $date
  my $mm   = substr( $date, 4, 2 );    # Extract month from $date
  my $dd   = substr( $date, 6, 2 );    # Extract day   from $date

  # Replace tokens
  $newStr =  $str;          
  $newStr =~ s/YYYY/$yyyy/g;           # Replace year 
  $newStr =~ s/MM/$mm/g;               # Replace month
  $newStr =~ s/DD/$dd/g;               # Replace day

  # Return modified string
  return( $newStr );
}
#EOC

END {}
