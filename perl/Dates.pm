#!/usr/bin/perl -w

#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Dates.pm
#
# !DESCRIPTION: Contains handy algorithms for converting dates to the 
#  Astronomical Julian Day and back, as well as related functions.
#\\
#\\
# !INTERFACE:
#
package Dates;
#
# !USES:
#
require 5.003;      # need this version of Perl or newer
use English;        # Use English language
use Carp;           # Get detailed error messages
use strict;         # Force explicit variable declarations (like IMPLICIT NONE)
#
# !PUBLIC MEMBER FUNCTIONS:
#  &julDay       : Converts YYYY/MM/DD to astronomical Julian Date 
#  &mint         : Computes modified integer function (used by &julDay)
#  &calDate      : Converts astronomical Julian Date to YYYY/MM/DD
#  &addDate      : Computes the YYYY/MM/DD a number of days away
#  &getDayOfYear : Converts YYYY/MM/DD to day of year (0-365 or 0-366)
#  &getDayOfWeek : Returns day of week (0-6) corresponding to a YYYY/MM/DD date
#  &getLocalTime : Returns local time in "YYYY/MM/DD hh:mm:ss" format
#  &getUtcTime   : Returns UTC   time in "YYYY/MM/DD hh:mm:ss" format
#
# !CALLING SEQUENCE:
#  use Dates qw( function-name1, function-name2, ... );
#
# !REVISION HISTORY:
#  bmy, 01 May 2002 - INITIAL VERSION
#  bmy, 10 Feb 2006 - added getDayOfYear routine
#  bmy, 22 Feb 2006 - bug fix in getDayOfYear routine
#  bmy, 07 Feb 2008 - added getDayOfWeek routine
#  bmy, 14 Feb 2008 - added getLocalTime, getUtcTime routines
#  bmy, 20 Feb 2008 - Bug fix: add 1 to month in getLocalTime, getUtcTime
#  23 May 2013 - R. Yantosca - Added ProTex headers
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
  @ISA       = qw( Exporter );                         # export method
  @EXPORT_OK = qw( &julDay       &mint         
                   &calDate      &addDate      
                   &getDayOfYear &getDayOfWeek 
                   &getLocalTime &getUtcTime );        # export on request
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: julDay 
#
# !DESCRIPTION: Computes the astronomical Julian Date from a calendar date.
#\\
#\\
# !INTERFACE:
#
sub julDay($$$) {
#
# !INPUT PARAMETERS:
#
  # $year  : Current year
  # $month : Current month
  # $day   : Current day (can be fractional, e.g. 17.25)
  my( $year, $month, $day ) = @_;
#
# !RETURN VALUE:
#
  # Astronomical Julian Date (initialize to zero)
  my $jd = 0.0
#
# !CALLING SEQUENCE:
#  $jd = &julDay( $year, $month, $day );
#
# !REMARKS:
#  (1) Algorithm taken from "Practical Astronomy With Your Calculator",
#       Third Edition, by Peter Duffett-Smith, Cambridge UP, 1992.
#  (2) Requires function mint(x), defined in this script.
#  (3) Hardwired for Gregorian dates only, since we are just going
#       to be using this for computing tomorrow's dates
#
# !REVISION HISTORY:
#  17 Aug 2001 - R. Yantosca - Initial version
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  my( $year1, $month1, $x1, $a  ) = ( 0,   0,   0.0, 0.0 );
  my( $b,     $c,      $d       ) = ( 0.0, 0.0, 0.0      );
  
  #=========================================================================
  # julDay begins here!
  #=========================================================================

  # Compute YEAR1 and MONTH1
  if ( ( $month == 1 ) || ( $month == 2 ) ) {
    $year1  = $year  - 1;
    $month1 = $month + 12;
  } else {
    $year1  = $year;
    $month1 = $month;
  }
  
  # Compute the A term
  $x1 = $year / 100.0;
  $a  = &mint( $x1 );
    
  # Compute the "B" term according to Gregorian or Julian calendar
  $b = 2.0 - $a + mint( $a / 4.0 );
  
  # Compute the "C" term for BC dates (YEAR1 <= 0 ) 
  # or AD dates (YEAR1 > 0)
  if ( $year1 < 0 ) {
    $x1 = ( 365.25 * $year1 ) - 0.75;
    $c  = &mint( $x1 );
  } else {
    $x1 = 365.25 * $year1;
    $c  = &mint( $x1 );
  }

  # Compute the D term
  $x1 = 30.6001 * ( $month1 + 1 );
  $d  = &mint( $x1 );
  
  # Compute the Julian day
  $jd = $b + $c + $d + $day + 1720994.5;
  
  # Return to calling program
  return $jd;
  
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: mint
#
# !DESCRIPTION: The modified integer function.  It is called by subroutine 
#  julDay above.
#\\
#\\
# !INTERFACE:
#
sub mint($) {
#
# !INPUT PARAMETERS:
#
  my( $x )  = @_;    # Value to be tested
#
# !RETURN VALUE:
#
  my $value = 0.0;   # Return value (initialized to zero)
#
# !CALLING SEQUENCE:
#  $y = &mint( $x );
#
# !REMARKS:
#  Definition:
#            { -INT( ABS( X ) );  X <  0
#     MINT = { 
#            {  INT( ABS( X ) );  X >= 0
#
# !REVISION HISTORY:
#  17 Aug 2001 - R. Yantosca - Initial version
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC

  if ( $x < 0 ) { 
    $value = -int( abs( $x ) );
  } else {
    $value = int( abs( $x ) );
  }
    
  # Return to calling program
  return $value;
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: caldate
#
# !DESCRIPTION: Converts an astronomical Julian day to a year, month, day.
#\\
#\\
# !INTERFACE:
#
sub calDate($) {
#
# !INPUT PARAMETERS:
#
  my( $jdIn ) = @_;   # Astronomical Julian Date
#
# !RETURN VALUE:
#
  my $y   = 0.0;     # Year
  my $m   = 0.0;     # Month
  my $day = 0.0;     # Day (can be fractional)
#
# !CALLING SEQUENCE:
#  ( $y, $m, $day ) = &calDate( $jdIn );
#
# !REMARKS:
#  Algorithm taken from "Practical Astronomy With Your Calculator",
#  Third Edition, by Peter Duffett-Smith, Cambridge UP, 1992.
#
# !REVISION HISTORY:
#  17 Aug 2001 - R. Yantosca - Initial version
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC	 
#
# !LOCAL VARIABLES:
#
  my $a    = 0.0;
  my $b    = 0.0;
  my $c    = 0.0;
  my $d    = 0.0;
  my $e    = 0.0;
  my $f    = 0.0;
  my $fday = 0.0;
  my $g    = 0.0;
  my $i    = 0.0;
  my $j    = 0.0;
  my $jd   = 0.0;

  #=========================================================================
  # calDate begins here!
  #=========================================================================
  $jd = $jdIn + 0.5;
  $i  = int( $jd );
  $f  = $jd - int( $i );
  
  if ( $i > 2299160.0 ) {
    $a = int( ( $i - 1867216.25 ) / 36524.25 );
    $b = $i + 1 + $a - int( $a / 4 );
  } else {
    $b = $i
  }

  # Compute intermediate quantities
  $c = $b + 1524.0;
  $d = int( ( $c - 122.1 ) / 365.25 );
  $e = int( 365.25 * $d );
  $g = int( ( $c - $e ) / 30.6001 );
    
  # day is the day number
  $day = $c - $e + $f - int( 30.6001 * $g );
  
  # fday is the fractional day number
  $fday = $day - int( $day );
  
  # m is the month number
  if ( $g < 13.5 ) {
    $m = $g - 1;
  } else {
    $m = $g - 13;
  }
  
  # y is the year number
  if ( $m > 2.5 ) {
    $y = $d - 4716.0;
  } else {
    $y = $d - 4715.0;
  }
  
  # Return values: year, month, day (incl. fractional part)
  return ( $y, $m, $day );
  
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: addDate
#
# !DESCRIPTION: Adds a specified number of days to a calendar date and 
#  returns the result.  This is useful for straddling the end of a month or 
#  the end of a year.
#\\
#\\
# !INTERFACE:
#
sub addDate($$) {
#
# !INPUT PARAMETERS:
#
  # $nymd0   : Starting YYYYMMDD date
  # $addDays : Number of days to add to $nymd0 (can be + or -)
  my( $nymd0, $addDays ) = @_;
#
# !RETURN VALUE:
#
  # New YYYYMMDD date
  my $nymd1 = 0.0
#
# !CALLING SEQUENCE:
#  $nymd1 = &addDate( $nymd0, $addDays );
#
# !REMARKS:
#  Algorithm taken from "Practical Astronomy With Your Calculator",
#  Third Edition, by Peter Duffett-Smith, Cambridge UP, 1992.
#
# !REVISION HISTORY:
#  17 Aug 2001 - R. Yantosca - Initial version
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC	 
#
# !LOCAL VARIABLES:
#
  my( $y0,    $m0, $d0 ) = ( 0,   0,   0.0 );
  my( $y1,    $m1, $d1 ) = ( 0,   0,   0.0 );
  my( $nhms1, $jd      ) = ( 0.0, 0.0      );
  
  #=========================================================================
  # addDate begins here!
  #========================================================================= 
  
  # Translate $nymd0 into $y0, $m0, $d0
  $y0 = int( $nymd0 / 10000 );
  $m0 = int( ( $nymd0 - int( $y0 * 10000 ) ) / 100 );
  $d0 = $nymd0 - int( $y0 * 10000 ) - int( $m0 * 100 );
  
  # Compute the astronomical julian day for the starting date
  $jd = &julDay( $y0, $m0, $d0 );
  
  # Add the offset to jd
  $jd = $jd + $addDays;
  
  # Convert the new Julian day back to a calendar date
  ( $y1, $m1, $d1 ) = &calDate( $jd );
    
  # Convert the new calendar date into YYYYMMDD format
  $nymd1 = int( $y1 * 10000 ) + int( $m1 * 100 ) + int( $d1 );

  # Return to calling program
  return $nymd1;
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: getDayOfYear
#
# !DESCRIPTION: Returns the day of year (0-365) or (0-366) corresponding to
#  a YYYYMMDD calendar date.
#\\
#\\
# !INTERFACE:
#
sub getDayOfYear($) {
#
# !INPUT PARAMETERS:
#
  my ( $nymd ) = @_;   # YYYYMMDD date
#
# !RETURN VALUE:
#
  my $doy      = 0.0   # Day of year
#
# !CALLING SEQUENCE:
#  $doy = &getDayOfYear( $nymd );
#
# !REMARKS:
#  Algorithm taken from "Practical Astronomy With Your Calculator",
#  Third Edition, by Peter Duffett-Smith, Cambridge UP, 1992.
#
# !REVISION HISTORY:
#  10 Feb 2006 - R. Yantosca - Initial version
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC	 
#
# !LOCAL VARIABLES:
#
  # Convert YMD to year-month-date
  my $year     = int( $nymd / 10000 );
  my $month    = int( ( $nymd - int( $year * 10000 ) ) / 100 );
  my $day      = $nymd - int( $year * 10000 ) - int( $month * 100 );

  # Get Julian day for 1st day of the year
  my $jd0      = julDay( $year, 1, 1 );

  # Get Julian day for start of the month
  my $jd1      = julDay( $year, $month, $day );

  # Day of year DDD value for 1st & last days of month
  $doy         = $jd1 - $jd0 + 1;

  # Return to the calling program
  return( $doy );
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: getDayOfYear
#
# !DESCRIPTION: Returns the day of week (0=Sun, 1=Mon, ..., 6=Sat) 
# corresponding to a YYYYMMDD calendar date
#\\
#\\
# !INTERFACE:
#
sub getDayOfWeek($) {
#
# !INPUT PARAMETERS:
#
  my ( $nymd ) = @_;   # YYYYMMDD date
#
# !RETURN VALUE:
#
  my $dow      = 0     # Day of week
#
# !CALLING SEQUENCE:
#  $dow = &getDayOfWeek( $nymd );
#
# !REMARKS:
#  Algorithm taken from "Practical Astronomy With Your Calculator",
#  Third Edition, by Peter Duffett-Smith, Cambridge UP, 1992.
#
# !REVISION HISTORY:
#  07 Feb 2008 - R. Yantosca - Initial version
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC	 
#
# !LOCAL VARIABLES:
#
  # Convert YMD to year-month-date
  my $year     = int( $nymd / 10000 );
  my $month    = int( ( $nymd - int( $year * 10000 ) ) / 100 );
  my $day      = $nymd - int( $year * 10000 ) - int( $month * 100 );

  # Get day of week -- Algorithm from Peter Duffett-Smith
  my $jd       = julDay( $year, $month, $day );
  my $tmp      = ( $jd + 1.5 ) / 7.0;
  $dow         = int( ( ( $tmp - int( $tmp ) ) * 7.0 ) + 0.5 );

  # Return to calling program
  return( $dow );
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: getLocalTime
#
# !DESCRIPTION: Returns the local time as a string in the format 
#  "YYYY/MM/DD hh:mm:ss".  Output is from the Perl localtime function. 
#\\
#\\
# !INTERFACE:
#
sub getLocalTime() {
#
# !RETURN VALUE:
#
    my $str = "";   # Local time string
#
# !CALLING SEQUENCE:
#  $str= &getLocalTime();
#
# !REVISION HISTORY:
#  14 Feb 2008 - R. Yantosca - Initial version
#  20 Feb 2008 - R. Yantosca - Bug fix: Need to add 1 to the month
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC	 
#
# !LOCAL VARIABLES:
#
  # Call the Perl localtime function
  my @r = localtime(); 

  # Format the output string
  $str  = sprintf( "%04d", $r[5] + 1900 ) . "/" . 
          sprintf( "%02d", $r[4] + 1    ) . "/" .
          sprintf( "%02d", $r[3]        ) . " " .
          sprintf( "%02d", $r[2]        ) . ":" .
          sprintf( "%02d", $r[1]        ) . ":" .
          sprintf( "%02d", $r[0]        );     

  # Return
  return( $str );
}
#EOC
#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !IROUTINE: getUtcTime
#
# !DESCRIPTION: Returns the UTC (aka GMT) time as a string in the format 
# "YYYY/MM/DD hh:mm:ss".  Output is from the Perl gmtime function.
#\\
#\\
# !INTERFACE:
#
sub getUtcTime() {
#
# !RETURN VALUE:
#
    my $str = "";   # Local time string
#
# !CALLING SEQUENCE:
#  $str = &getUtcTime();
#
# !REVISION HISTORY:
#  14 Feb 2008 - R. Yantosca - Initial version
#  20 Feb 2008 - R. Yantosca - Bug fix: Need to add 1 to the month
#  29 Aug 2013 - R. Yantosca - Added ProTeX headers
#EOP
#------------------------------------------------------------------------------
#BOC	 
#
# !LOCAL VARIABLES:
#
  # Call the Perl gmtime function
  my @r = gmtime(); 

  # Format the output string
  $str  = sprintf( "%04d", $r[5] + 1900 ) . "/" . 
          sprintf( "%02d", $r[4] + 1    ) . "/" .
          sprintf( "%02d", $r[3]        ) . " " .
          sprintf( "%02d", $r[2]        ) . ":" .
          sprintf( "%02d", $r[1]        ) . ":" .
          sprintf( "%02d", $r[0]        );     

  # Return
  return( $str );
}
#EOC

END {}
