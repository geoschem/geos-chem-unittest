#!/usr/bin/perl -w

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
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
require 5.003;                      # Need this version of Perl or newer
use English;                        # Use English language
use Carp;                           # Strict error checking
use strict;                         # IMPLICIT NONE syntax
use Dates qw( &julDay &calDate );   # Get routines from Dates.pm
#
# !PUBLIC MEMBER FUNCTIONS:
#  &baseName      : Returns a directory name minus the full path
#  &checkDir      : Ensures that a directory exists
#  &cleanDir      : Removes files from a directory
#  &fmtStr        : Pads a date string w/ leading zeroes if necessary
#  &makeInputGeos : Creates a new input.geos file from a template file
#  &parse         : Parses a line separated by ":" and returns the 2nd value
#  &replaceDate   : Replaces YYYY, MM, DD tokens in a string w/ date values
#  &makeHemcoCfg  : Creates a new HEMCO_Config.rc from a template file
#  &makeHcoSaCfg  : Creates a new HEMCO_sa_Config.rc from a template file
#  &readResults   : Reads unit test results into a Perl hash
#  &makeTxtMatrix : Summarizes unit test results into an text file
#  &makeMatrix    : Summarizes unit test results into an HTML file
# 
# !CALLING SEQUENCE:
#  use UtUtils qw( function-name1, function-name2, ... );
#
# !REVISION HISTORY:
#  20 Jun 2013 - R. Yantosca - Initial version, moved other routines here
#  30 Jul 2013 - R. Yantosca - Added function &checkDir
#  28 Aug 2013 - R. Yantosca - Added functions &cleanDir, $baseName
#  24 Mar 2014 - R. Yantosca - Add UNITTEST hash and 1 at end of module
#  24 Mar 2014 - R. Yantosca - Add &readResults, &makeMatrix routines
#  24 Mar 2014 - R. Yantosca - Update ProTeX headers
#  27 Jun 2014 - R. Yantosca - Add &makeHemcoCfg routine
#  22 Jun 2015 - R. Yantosca - Add &makeTxtMatrix routine; updated comments
#  19 May 2017 - M. Sulprizio- Add &makeHcoSaCfg routine for HEMCO standalone
#EOP
#------------------------------------------------------------------------------
#BOC

BEGIN {

  #=========================================================================
  # The BEGIN method lists the names to export to the calling routine
  #=========================================================================
  use Exporter ();
  use vars     qw( $VERSION @ISA @EXPORT_OK );

  $VERSION   = 1.00;                        # version number
  @ISA       = qw( Exporter         );      # export method
  @EXPORT_OK = qw( &baseName
                   &checkDir
                   &cleanDir
                   &fmtStr
                   &makeHemcoCfg        
                   &makeHcoSaCfg        
                   &makeInputGeos 
                   &makeGCHPcfg
                   &parse
                   &replaceDate
                   &readResults
                   &makeMatrix      
                   &makeTxtMatrix   ); 
}
#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
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
#                  GEOS-Chem Global Chemical Transport Model                  !
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
#                  GEOS-Chem Global Chemical Transport Model                  !
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
#  05 Sep 2013 - R. Yantosca - Now can remove subdirs of $dir
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

  # Remove log files and subdirectories of $dir.
  # Skip over the "." and ".." directories.
  foreach $file ( @files ) {
    if ( !( $file =~ m/^\./ ) ) {
      if ( -d "$dir/$file" ) { $cmd = "rm -rf $dir/$file"; }
      else                   { $cmd = "rm -f $dir/$file";  }
      print "$cmd\n";
      qx( $cmd );
    }
  }	
}
#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
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
#  Used by routines &makeInputGeos and &makeGCHPcfg below.
#
# !REVISION HISTORY:
#  23 May 2013 - R. Yantosca - Initial version, based on NRT-ARCTAS
#  11 Aug 2017 - E. Lundgren - Added padding if $tmp between 1 and 100
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  my $tmp = int( $num );

  # Pad w/ proper # of leading zeroes (if necessary)
  if    ( $tmp == 0                      ) { $str = "000000";    }
  elsif ( $tmp >= 1   && $tmp < 10       ) { $str = "00000$tmp";   }
  elsif ( $tmp >= 10   && $tmp < 100     ) { $str = "0000$tmp";   }
  elsif ( $tmp >= 100   && $tmp < 1000   ) { $str = "000$tmp";   }
  elsif ( $tmp >= 1000  && $tmp < 10000  ) { $str = "00$tmp";    }
  elsif ( $tmp >= 10000 && $tmp < 100000 ) { $str = "0$tmp";     }
  else                                     { $str = "$tmp";      }

  # Return to calling program
  return( $str );
}
#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
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
  # $met      : Met field type  (passed via MET flag in G-C compilation)
  # $dataRoot : GEOS-chem root data directory
  # $template : Path for input.geos "template" file
  # $fileName : Path for input.geos file (w/ dates replaced)
  my ( $date1,  $time1,  $date2, $time2, $met, $dataRoot,
       $inFile, $outFile ) = @_;
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
#  13 Jul 2016 - M. Sulprizio- Pass met field as argument and use to replace
#                              {MET} token in input.geos
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

    # Replace tokens
    $line =~ s/{DATE1}/$dStr1/g;
    $line =~ s/{TIME1}/$tStr1/g;
    $line =~ s/{DATE2}/$dStr2/g; 
    $line =~ s/{TIME2}/$tStr2/g;
    $line =~ s/{MET}/$met/g;
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
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: makeGCHPcfg
#
# !DESCRIPTION: Constructs the "runConfig.sh" or "CAP.rc" files for GCHP.  
#  It reads a pre-defined template file and then just replaces tokens with 
#  the values passed via the argument list. It also calculates duration 
#  based on start and end dates and times passed in.
#\\
#\\
# !INTERFACE:
#
sub makeGCHPcfg($$$$$$$) {
#
# !INPUT PARAMETERS:
#
  # $date1    : Starting date for GEOS-Chem model run (e.g. 20040101) 
  # $time1    : Starting time for GEOS-Chem model run (e.g. 000000  ) 
  # $date2    : Ending   date for GEOS-Chem model run (e.g. 20040102)
  # $time2    : Ending   time for GEOS-Chem model run (e.g. 000000  ) 
  # $sim      : Simulation name
  # $template : Path for "template" file
  # $fileName : Path for output file (w/ dates and duration replaced)
  my ( $date1,  $time1,  $date2, $time2, $sim, $inFile, $outFile ) = @_;
#
# !CALLING SEQUENCE:
# &makeGCHPcfg( 20130101, 000000, 
#                 20130102, 000000, 
#                "runConfig.template", "runConfig.sh" );
#
# !REVISION HISTORY:
#  09 Aug 2017 - E. Lundgren - Initial version, adapted from makeInputGeos
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
  my $durStrDate = ""; 
  my $durStrTime = "";

  my $yr1 = 0;
  my $mo1 = 0;
  my $day1 = 0;
  my $hr1 = 0;
  my $yr2 = 0;
  my $mo2 = 0;
  my $day2 = 0;
  my $hr2 = 0;
  my $dyr = 0;
  my $dmo = 0;
  my $dday = 0;
  my $dhr = 0;
  my $ddayoffset = 0;
  my $dmooffset = 0;
  my $dyroffset = 0;
  my $modays = 31;
  my $mo1i = 0;

  #------------------------------  
  # Read template file
  #------------------------------ 
  
  # Read template "runConfig.sh" file into an array
  open( I, "$inFile" ) or croak( "Cannot open $inFile!\n" );
  @lines = <I>;
  close( I );

  #------------------------------  
  # Create output file
  #------------------------------ 

  # Open file
  open( O, ">$outFile") or die "Can't open $outFile\n";
  
  #---------------------------------------  
  # Determine run duration as Start - End
  # NOTE: does not handle leap years
  #---------------------------------------
  $hr1  = substr( $time1, 0, 2 );
  $hr2  = substr( $time2, 0, 2 );
  $day1 = substr( $date1, 6, 2 );
  $day2 = substr( $date2, 6, 2 );
  $mo1  = substr( $date1, 4, 2 );
  $mo2  = substr( $date2, 4, 2 );
  $yr1  = substr( $date1, 0, 4 );
  $yr2  = substr( $date2, 0, 4 );
  
  # Calculate # hours
  $dhr = int($hr2) - int($hr1);
  if ( $dhr < 0 ) {
    $dhr = 24 + $dhr;
    $ddayoffset = 1;
  }
  
  # Calculate # days
  $dday = int($day2) - int($day1) - $ddayoffset;
  if ( $dday < 0 ) {
    $mo1i = int($mo1);
    if ( $mo1i eq 2 ) {
      if ( ( int($yr1) % 4 eq 0 && int($yr1) % 100 ne 0 ) 
  	   || int($yr1) % 400 eq 0 ) {
  	$modays = 29;
      } else {
        $modays = 28;
      }
    } elsif ( $mo1i eq 4 || $mo1i eq 6 || $mo1i eq 9 || $mo1i eq 11 ) {
      $modays = 30;
    }
    $dday = $modays + $dday;
    $dmooffset = 1;
  }
  
  # Calculate # months
  $dmo = int($mo2) - int($mo1) - $dmooffset;
  if ( $dmo < 0 ) {
    $dmo = 12 + int($dmo);
    $dyroffset = 1;
  }
  
  # Calculate # year
  $dyr = int($yr2) - int($yr1) - $dyroffset;
  
  # Set the date and hour strings to be put into the file
  $durStrDate = &fmtStr( int($dyr)*10000 + int($dmo)*100 + int($dday) );
  $durStrDate = "00$durStrDate";
  $durStrTime = &fmtStr( $dhr * 10000 );
  
  # Loop thru each line
  foreach $line ( @lines ) {
    
    # Remove newline character
    chomp( $line );
  
    # Replace tokens
    if ( $outFile =~ m/GCHP.rc/ || $outFile =~ m/runConfig.sh/ ) {
      if  ( $sim =~ m/RnPbBe/ ) {
	$line =~ s/{SIMULATION}/${sim}Pasv/g;
      } else {
	$line =~ s/{SIMULATION}/$sim/g;
      }      
    }
    if ( !($outFile =~ m/GCHP.rc/) ) {
      $line =~ s/{DATE1}/$dStr1/g;
      $line =~ s/{TIME1}/$tStr1/g;
      $line =~ s/{DATE2}/$dStr2/g; 
      $line =~ s/{TIME2}/$tStr2/g;
      $line =~ s/{dYYYYMMDD}/$durStrDate/g;
      $line =~ s/{dHHmmss}/$durStrTime/g;
    }    

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
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: makeHemcoCfg
#
# !DESCRIPTION: Constructs the "HEMCO_Config.rc" file for GEOS-Chem.  It reads 
#  a pre-defined template file and then just replaces tokens with the values
#  passed via the argument list.
#\\
#\\
# !INTERFACE:
#
sub makeHemcoCfg($$$$$$$) {
#
# !INPUT PARAMETERS:
#
  # $infile   : HEMCO_Config template file w/ replaceable tokens
  # $met      : Met field type  (passed via MET flag in G-C compilation)
  # $grid     : Horizontal grid (passed via GRID flag in G-C compilation)
  # $nest     : Nested grid suffix (i.e. CH, EU, NA, AS, etc.)
  # $simType  : Simulation type (passed via GRID flag in G-C compilation)
  # $verbose  : HEMCO verbose setting (0=no verbose, 3=most verbose)
  # $warnings : HEMCO warnings setting (0=no warnings, 3=most warnings)
  # $rootDir  : Filepath to HEMCO emissions directory
  # $outFile  : HEMCO_Config.rc file w/ all tokens replaced
  my ( $inFile,  $start,   $met,      $grid,    $nest,   
       $simType, $verbose, $warnings, $rootDir, $outFile ) = @_;
#
# !CALLING SEQUENCE:
# &makeHemcoCfg( "HEMCO_Config.template", 20130101, 000000,     
#                "geosfp",                "4x5",    "-",      
#                 "tropchem",             "3",      "3",  
#                 "HEMCO_Config.rc" )
#                 
#
# !REMARKS:
#
# !REVISION HISTORY:
#  27 Jun 2014 - R. Yantosca - Initial version
#  30 Jun 2014 - R. Yantosca - Now accept $nest via the argument list
#  02 Jul 2014 - R. Yantosca - Now accept $start via the argument list
#  02 Jul 2014 - R. Yantosca - Now replace the {LNOX} token
#  23 Sep 2014 - R. Yantosca - Now replace the {LEVRED} and {LEVFULL} tokens
#  19 May 2015 - R. Yantosca - Add $verbose, $warnings as arguments so that
#                              we can replace {VERBOSE} and {WARNINGS} tokens
#  03 Aug 2015 - M. Sulprizio- Remove LNOX token since it is no longer needed.
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # Strings
  my @lines      = "";
  my $line       = "";
  my $levReduced = "";
  my $levFull    = "";

  # Scalars
  my $date       = 0;

  #-------------------------------------------------------------------------  
  # Read template file
  #-------------------------------------------------------------------------

  # Read template "input.geos" file into an array
  open( I, "$inFile" ) or croak( "Cannot open $inFile!\n" );
  @lines = <I>;
  close( I );

  #-------------------------------------------------------------------------
  # Define the values used to replace the {LEVRED} and {LEVFULL} tokens in 
  # file names.  These are needed for certain specialty simulations that 
  # read archived OH or O3 concentrations.  
  #-------------------------------------------------------------------------
  $levReduced = "47L";
  $levFull = "72L";

  #-------------------------------------------------------------------------
  # Create HEMCO_Config file
  #-------------------------------------------------------------------------

  # Open file
  open( O, ">$outFile") or die "Can't open $outFile\n";

  # Loop thru each line
  foreach $line ( @lines ) {
    
    # Remove newline character
    chomp( $line );

    # Replace start & end dates
    $line =~ s/{ROOT}/$rootDir/g;
    $line =~ s/{MET}/$met/g;
    $line =~ s/{GRID}/$grid/g;
    $line =~ s/{NEST}/$nest/g;
    $line =~ s/{SIM}/$simType/g;
    $line =~ s/{LEVRED}/$levReduced/g;
    $line =~ s/{LEVFULL}/$levFull/g;
    $line =~ s/{VERBOSE}/$verbose/g;
    $line =~ s/{WARNINGS}/$warnings/g;

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
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: makeHcoSaCfg
#
# !DESCRIPTION: Constructs the "HEMCO_sa_Config.rc" file for the HEMCO
#  standalone.  It reads a pre-defined template file and then just replaces
#  tokens with the values passed via the argument list.
#\\
#\\
# !INTERFACE:
#
sub makeHcoSaCfg($$$$$$$) {
#
# !INPUT PARAMETERS:
#
  # $infile   : HEMCO_sa_Config template file w/ replaceable tokens
  # $met      : Met field type  (passed via MET flag in G-C compilation)
  # $grid     : Horizontal grid (passed via GRID flag in G-C compilation)
  # $nest     : Nested grid suffix (i.e. CH, EU, NA, AS, etc.)
  # $simType  : Simulation type (passed via GRID flag in G-C compilation)
  # $verbose  : HEMCO verbose setting (0=no verbose, 3=most verbose)
  # $warnings : HEMCO warnings setting (0=no warnings, 3=most warnings)
  # $rootDir  : Filepath to data directory
  # $outFile  : HEMCO_sa_Config.rc file w/ all tokens replaced
  my ( $inFile,  $start,   $met,      $grid,    $nest,   
       $simType, $verbose, $warnings, $rootDir, $outFile ) = @_;
#
# !CALLING SEQUENCE:
# &makeHcoSaCfg( "HEMCO_sa_Config.template", 20130101, 000000,     
#                "geosfp",                   "4x5",    "-",      
#                "tropchem",                 "3",      "3",  
#                "HEMCO_sa_Config.rc" )
#                 
#
# !REMARKS:
#
# !REVISION HISTORY:
#  19 May 2017 - M. Sulprizio- Initial version based on MakeHemcoCfg
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # Strings
  my @lines      = "";
  my $line       = "";
  my $levReduced = "";
  my $levFull    = "";
  my $metDir     = "";
  my $gridDir    = "";

  # Scalars
  my $date       = 0;

  #-------------------------------------------------------------------------  
  # Read template file
  #-------------------------------------------------------------------------

  # Read template "input.geos" file into an array
  open( I, "$inFile" ) or croak( "Cannot open $inFile!\n" );
  @lines = <I>;
  close( I );

  #-------------------------------------------------------------------------
  # Define the values used to replace the {LEVRED} and {LEVFULL} tokens in 
  # file names.  These are needed for certain specialty simulations that 
  # read archived OH or O3 concentrations.  
  #-------------------------------------------------------------------------
  $levReduced = "47L";
  $levFull = "72L";

  #-------------------------------------------------------------------------
  # Define met and grid strings used in data directory names
  #-------------------------------------------------------------------------
  if ( $met =~ m/geosfp/ ) {
    $metDir = "GEOS_FP";
  } elsif ( $met =~ m/merra2/ ) {
    $metDir = "MERRA2";
  }

  if ( $grid =~ m/4x5/ ) {
    $gridDir = "4x5";
  } elsif ( $grid =~ m/2x25/ ) {
    $gridDir = "2x2.5";
  } elsif ( $grid =~ m/05x0625/ ) {
    $gridDir = "0.5x0.625". "_" . uc($nest);
  } elsif ( $grid =~ m/025x03125/ ) {
    $gridDir = "0.25x0.3125" . "_" . uc($nest);
  }

  #-------------------------------------------------------------------------
  # Create HEMCO_Config file
  #-------------------------------------------------------------------------

  # Open file
  open( O, ">$outFile") or die "Can't open $outFile\n";

  # Loop thru each line
  foreach $line ( @lines ) {
    
    # Remove newline character
    chomp( $line );

    # Replace start & end dates
    $line =~ s/{DATA_ROOT}/$rootDir/g;
    $line =~ s/{MET}/$met/g;
    $line =~ s/{GRID}/$grid/g;
    $line =~ s/{NEST}/$nest/g;
    $line =~ s/{SIM}/$simType/g;
    $line =~ s/{LEVRED}/$levReduced/g;
    $line =~ s/{LEVFULL}/$levFull/g;
    $line =~ s/{VERBOSE}/$verbose/g;
    $line =~ s/{WARNINGS}/$warnings/g;
    $line =~ s/{MET_DIR}/$metDir/g;
    $line =~ s/{GRID_DIR}/$gridDir/g;

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
#                  GEOS-Chem Global Chemical Transport Model                  !
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
#  22 Jun 2015 - R. Yantosca - Now can correctly handle strings with
#                              more than one : character
#EOP
#------------------------------------------------------------------------------
#BOC

  # Take the text following the colon
  my @result = split( ':', $str );
  
  # If there are more than 2 substrings, then lump the other
  # substrings into the second substring, and preserve the colon
  if ( scalar( @result ) > 2 ) {
    for ( my $i=2; $i < scalar( @result ); $i++ ) {
      $result[1] .= ":$result[$i]";
    }
  }

  # Strip leading spaces
  $result[1] =~ s/^\s+//; 

  # Strip trailing spaces
  $result[1] =~ s/^\s+$//;

  # Return to calling routine
  return( $result[1] );
}
#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
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
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: readResults
#
# !DESCRIPTION: Reads a results.log file from a set of unit test simulations
#  and determines the color (red, green, yellow) that will be displayed in
#  each slot of the unit test matrix web and text pages.  RED = unsuccessful, 
#  GREEN = successful, YELLOW = needs further investigation.
#\\
#\\
# !INTERFACE:
#
sub readResults($$) {
#
# !INPUT PARAMETERS:
#
  # $runRoot  : Unit test root run directory
  # $fileName : File containing unit test results (i.e. a "*.results.log")
  my ( $runRoot, $fileName ) = @_;  
#
# !RETURN VALUE:
#
  # Hash that matches a result color (red, yellow, green) to each unit test
  my %unitTests              = ();
#
# !CALLING SEQUENCE:
#  %unitTest = &readResults( $runDir, $fileName );
#
# !REVISION HISTORY:
#  21 Mar 2014 - R. Yantosca - Initial version
#  24 Mar 2014 - R. Yantosca - Now return the %unitTests hash
#  24 Mar 2014 - R. Yantosca - Now get version, date, description
#  02 Jul 2014 - R. Yantosca - Improved the search method for HEMCO, UCX files
#  25 Mar 2015 - R. Yantosca - Now always validate the HEMCO restart files
#  25 Mar 2015 - R. Yantosca - The UCX PSC restart is removed, so ignore it
#  14 Jul 2016 - M. Sulprizio- Remove initialization of unitTests. UT run dirs
#                              are now consolidated so using 'ls -1 $runRoot'
#                              to populate unitTests no longer works. Instead
#                              unitTests is populated when the log file is read.
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # Scalars
  my $bpch     = 1;
  my $rst      = 1;
  my $ncDiag   = 1;
  my $isNcDiag = 1;
  my $hemco    = 1;
  my $color    = "";
  my $utName   = "";
  my $version  = "";
  my $dateRan  = "";
  my $describe = "";
  my $makeCmd  = "";

  # HTML color values
  my $WHITE    = "#FFFFFF";
  my $RED      = "#FF0000";
  my $GREEN    = "#00FF00";
  my $YELLOW   = "#FFFF00";

  # Arrays
  my @txt      = ();
  my @subStr   = ();

  #---------------------------------------------------------------------------
  # Read the results.log file
  #---------------------------------------------------------------------------

  # Read entire file into an array and remove newlines
  open( I, "<$fileName" ) or die "Cannot open $fileName!\n";
  chomp( @txt = <I> );
  close( I );

  # Loop thru each line in the file; parse information into global variables
  for ( my $i = 0; $i < scalar( @txt ); $i++ ) {

    #-------------------------------------------------------------------------
    # Get the version number and date submitted
    #-------------------------------------------------------------------------
    if ( $txt[$i] =~ m/GEOS-CHEM UNIT TEST RESULTS FOR VERSION/ ) {

      # Version number
      @subStr   =  split( ':', $txt[$i] );
      $version  =  $subStr[1];
      $version  =~ s/^\s+//; 
      $version  =~ s/^\s+$//;

      # Version number
      @subStr   =  split( '\@', $txt[++$i] );
      $dateRan  =  $subStr[1];
      $dateRan  =~ s/^\s+//; 
      $dateRan  =~ s/^\s+$//;

      # Description
      ++$i;     
      @subStr   =  split( '\:', $txt[++$i] );
      $describe =  $subStr[1];
      $describe =~ s/^\s+//; 
      $describe =~ s/^\s+$//;

      # Make command
      ++$i;     
      @subStr   =  split( '\:', $txt[++$i] );
      $makeCmd  =  $subStr[1];
      $makeCmd  =~ s/^\s+//; 
      $makeCmd  =~ s/^\s+$//;

      # Store in the hash
      $unitTests{ "UNIT_TEST_VERSION"  } = $version;
      $unitTests{ "UNIT_TEST_DATE"     } = $dateRan;
      $unitTests{ "UNIT_TEST_DESCRIBE" } = $describe;
      $unitTests{ "UNIT_TEST_MAKECMD"  } = $makeCmd;
    }
    
    #-------------------------------------------------------------------------
    # Get the name of the each unit test run directory
    #-------------------------------------------------------------------------
    if ( $txt[$i] =~ m/VALIDATION OF GEOS-CHEM OUTPUT FILES/ ) {
      @subStr = split( ':', $txt[++$i] );
      $utName = $subStr[1];

      # Strip white spaces
      $utName =~ s/ //g;

      # Change name of complexSOA_SVPOA to SVPOA to avoid problems
      if ( $utName =~ m/complexSOA_SVPOA/ ) {
           $utName =~ s/complexSOA_SVPOA/SVPOA/g; }

      # Check if the netCDF diagnostics are present
      if ( $txt[++$i] =~ m/NC_DIAG=y/ ) { $isNcDiag = 1; }
      else                              { $isNcDiag = 0; }

      # Initialize flags
      $bpch   = 1;
      $ncDiag = 1;
      $rst    = 1;
      $hemco  = 1;

      # Check the results of the BPCH file    
      for ( my $j = 0; $j < 6; $j++ ) { 
	if ( $txt[++$i] =~ m/DIFFERENT/ ) { $bpch = -1; }
      }

      # Check the results of the RESTART file    
      for ( my $j = 0; $j < 6; $j++ ) { 
	if ( $txt[++$i] =~ m/DIFFERENT/ ) { $rst = -1; }
      }

      # Check the results of the NETCDF DIAGNOSTICS file (aka "History")
      if ( $isNcDiag ) { 
	for ( my $j = 0; $j < 6; $j++ ) { 
	  if ( $txt[++$i] =~ m/DIFFERENT/ ) { $ncDiag = -1; }
        }
      } 

      # Check the results of the HEMCO restart file    
      for ( my $j = 0; $j < 6; $j++ ) { 
	if ( $txt[++$i] =~ m/DIFFERENT/ ) { $hemco = -1; }
      }

      #-----------------------------------------------------------------------
      # Assign a color to the unit test output
      # GREEN  = IDENTICAL
      # YELLOW = RESTART FILES IDENTICAL, BUT BPCH FILES DIFFERENT
      # RED    = RESTART FILES DIFFERENT
      #-----------------------------------------------------------------------
      $color = $GREEN;
      if ( $bpch == -1 || $ncDiag == -1 ) { $color = $YELLOW; }
      if ( $rst  == -1 || $hemco  == -1 ) { $color = $RED;    }

      # Add the color to the UNITTEST hash
      $unitTests{ $utName } = $color;
    }	
  }				

  # Return normally
  return( %unitTests );
}
#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: makeMatrix
#
# !DESCRIPTION: Creates a unit test matrix web page from a template file.
#  Tokens in the template file will be replaced with the colors (red, green,
#  or yellow) corresponding to the results of each unit test.
#\\
#\\
# !INTERFACE:
#
sub makeMatrix($$%) {
#
# !INPUT PARAMETERS:
#
  # $template  : Template HTML page for the unit test results matrix
  # $webFile   : Output HTML page for unit test results that will be created 
  # %unitTests : Hash contaning the unit test results (from &readResults)
  my ( $template, $webFile, %unitTests ) = @_;
#
# !CALLING SEQUENCE:
#  &makeMatrix( $template, $webFile, %unitTests );
#
# !REVISION HISTORY:
#  21 Mar 2014 - R. Yantosca - Initial version
#  24 Mar 2014 - R. Yantosca - Now pass %unitTests hash as an argument
#  07 Apr 2014 - R. Yantosca - Now make $webFile chmod 664
#  14 Jul 2016 - M. Sulprizio- Update to replace #FFFFFF string with utColor 
#                              if utName matches the name in the html file
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # Scalar
  my $utColor = "";
  my $utName  = "";
  my $line    = "";
  my $name    = "";

  # Arrays
  my @txt     = ();
  my @subStr  = ();

  #---------------------------------------------------------------------------
  # makeMatrix begins here!
  #---------------------------------------------------------------------------

  # Read entire file into an array and remove newlines
  open( I, "<$template" ) or die "Cannot open $template!\n";
  chomp( @txt = <I> );
  close( I );

  # Open output file
  open( O, ">$webFile" ) or die "Cannot open $webFile!\n";

  # Loop over all lines in the text
  foreach $line ( @txt ) {

    # Strip newlines
    chomp( $line );
 
    # Loop over unit test names
    while ( ( $utName, $utColor ) = each( %unitTests ) ) { 

      # Text-replace header information
      if ( $line =~ m/UNIT_TEST/ ) {
        $line =~ s/$utName/$utColor/g;
      }

      # Look for bgcolor="#FFFFFF" (white)
      if ( index ($line, "\#FFFFFF") != -1 ) {

        # Obtain unit test name from html file
        # Names are in html comments <!-- -->, so check for '--' and split
        if ( index ($line, '--') != -1 ) {

          @subStr = split( '--', $line );
          $name   = $subStr[1];
          $name   =~ s/^\s+//; 
          $name   =~ s/\s+$//;

	  # Check if utName matches the name in html file
          if ( $utName =~ m/$name/ ) {

            # Text-replace the proper color for each unit test
            $line =~ s/\#FFFFFF/$utColor/g;

	  }
        }
      }
    }	

    # Write to output file
    print O "$line\n";
  }

  # Close output file
  close( O );

  # Make the output file chmod 666 (read/write for everyone)
  # This may be necessary for the website upload
  chmod( 0664, $webFile );

  # Return normally
  return( $? );
}
#EOC
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: makeTxtMatrix
#
# !DESCRIPTION: Prints out a simple text file with the results of the
#  unit tests as contained in the log file.  This can be useful if you are
#  running the GEOS-Chem unit tests on a computational cluster where
#  you cannot send the HTML file w/ results to a web server.
#\\
#\\
# !INTERFACE:
#
sub makeTxtMatrix($%) {
#
# !INPUT PARAMETERS:
#
  # $txtFile   : Text file to contain summary of unit test results
  # %unitTests : Hash contaning the unit test results (from &readResults)
  my ( $txtFile, %unitTests ) = @_;
#
# !CALLING SEQUENCE:
#  &makeTxtMatrix( $txtFile, %unitTests );
#
# !REVISION HISTORY:
#  21 Mar 2014 - R. Yantosca - Initial version, based on &makeMatrix
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # Strings
  my $utColor = "";
  my $utName  = "";

  # Scalars
  my $padSpc  = 0;

  #---------------------------------------------------------------------------
  # makeTxtMatrix begins here!
  #---------------------------------------------------------------------------

  # Open output file
  open( O, ">$txtFile" ) or die "Cannot open $txtFile!\n";

  # Write header line
  print O "GEOS-Chem Unit Test             : RESULT\n";
  print O '-'x42 . "\n";

  # Print out the results from each unit test
  while ( ( $utName, $utColor ) = each( %unitTests ) ) { 

    # Skip unit tests that weren't done
    if ( !( $utName =~ m/UNIT_TEST/ ) ) { 
      if ( !( $utColor =~ m/#FFFFFF/ ) ) {

        # Replace HTML colors with descriptive names
	$utColor =~ s/#FF0000/RED/g;
	$utColor =~ s/#FFFF00/YELLOW/g;
	$utColor =~ s/#00FF00/GREEN/g;

	# Pad so that all results line up
	$padSpc = 32 - length( $utName );

	# Print the results to the text file
	print O "$utName". ' 'x$padSpc, ": $utColor\n";
      }
    }
  }	

  # Close output file
  close( O );

  # Make the output file chmod 666 (read/write for everyone)
  # This may be necessary for the website upload
  chmod( 0664, $txtFile );

  # Return normally
  return( $? );
}
#EOC
#------------------------------------------------------------------------------

# End of module: Return true
1;

END {}
