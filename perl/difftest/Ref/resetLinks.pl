#!/usr/bin/perl -w

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: resetLinks.pl
#
# !DESCRIPTION: Resets the symbolic links to make sure that they are pointing
#  to those in the ../Dev directory.  This is useful if you copy a difftest
#  directory, in order to prevent the links from still pointing to the
#  old location.
#\\
#\\
# !CALLING SEQUENCE:
#  resetLinks.sh
#
# !REMARKS:
#
# !REVISION HISTORY:
#  06 Jan 2015 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# Scalars
my $file  = "";
my $cmd   = "";

# Arrays
my @files = ();

# Read files from directory
opendir( D, "../Dev" ) or die( "Could not open '../Dev'" );
@files = readdir( D );
closedir( D );

foreach $file ( @files ) {

  # Remove newlines
  chomp( $file );
 
  # Re-establish links for files (*.dat, *.rc, *.geos extensions)
  # NOTE: $ is the regexp which means "look at the end of the line"
  if ( $file =~ m/.dat$/ || $file =~ m/.rc$/  || $file =~ m/.geos$/ ) {
    $cmd = "rm -f $file; ln -s ../Dev/$file .";
    print "$cmd\n";
    qx/$cmd/;
  }

}

exit( $? );
