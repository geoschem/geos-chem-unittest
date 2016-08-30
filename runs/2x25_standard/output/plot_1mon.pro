;-----------------------------------------------------------------------
;+
; NAME:
;        PLOT_1MON
;
; PURPOSE:
;        Convenience program which calls the IDL programs to create 
;        plots from GEOS-Chem 1-month benchmark output.
;
; CATEGORY:
;        Benchmarking
;
; CALLING SEQUENCE:
;        PLOT_1MON
;
; INPUTS:
;        INFILE -> Filename containing the version and directory
;             information of the 2 GEOS-Chem 1-month benchmark 
;             simulations to be compared.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External subroutines required:
;        ==============================
;        BENCHMARK_1MON   MAKE_PDF
; 
; REQUIREMENTS:
;        References routines from the GAMAP package.
;
; NOTES:
;        A file that contains the information about both benchmark
;        simulations being compared needs to be present in the
;        same directory.;        
;
; EXAMPLE:
;        PLOT_1MON
;
;             ; Creates 1-month benchmark plots (PS and PDF formats)
; 
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2011: VERSION 1.00
;        bmy, 23 Jun 2011: - Skip profile plots, these are superseded
;                            by the zonal mean difference plots
;                          - Add VERSION 
;        bmy, 09 Jun 2011: VERSION 1.01
;                          - Now search for default file
;
;-
; Copyright (C) 2011, Bob Yantosca, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine plot_1mon"
;-----------------------------------------------------------------------


pro Plot_1mon, InFile, _EXTRA=e
   
   ; Search for default input file
   if ( N_Elements( InFile ) eq 0 ) then begin

      ; Assume default file has *.1mon extension
      InFile = MFindFile( '*.1mon' )
      
      ; Exit w/ error
      if ( N_Elements( InFile ) gt 1 ) then begin
         Message, 'Found more than one input file!', /Info
         return
      endif
         
      ; MFINDFILE returns an array, so cast INFILE to a string scalar
      InFile = InFile[0]

   endif

   ; Create the benchmark plots!
   Benchmark_1Mon, InFile, /No_Profiles, /No_2D_Met, /No_3D_Met, _EXTRA=e

   ; To customize set of maps, uncomment all of the below and then
   ; selectively comment out lines
;   Benchmark_1Mon, InFile, $ 
;        /NO_AOD_DIFFS,  $; difference maps of aerosol optical depths.
;        /NO_AOD_MAPS,   $; aerosol optical depths.
;        /NO_BUDGET,     $; table of Ox and CO budgets, mean OH and CH3CCl3 LT.
;        /NO_CONC_MAPS,  $; tracer concentrations maps
;        /NO_DIFFS,      $; tracer differences maps
;        /NO_EMISSIONS,  $; table of emissions totals. 
;        /NO_FREQ_DIST,  $; frequency distribution histogram plot.
;        /NO_JVALUES,    $; J-value ratios maps
;        /NO_JVDIFFS,    $; J-value differences maps
;        /NO_JVMAPS,     $; J-values maps
;        /NO_PROFILES,   $; plot of vertical profiles of tracer differences
;        /NO_RATIOS,     $; tracer ratios maps
;        /NO_STRATDIFF,  $; zonal mean differences maps in strat (100-0.01hPa)
;        /NO_STRATCONC,  $; zonal mean conc maps in strat (100-0.01hPa)
;        /NO_ZONALDIFF,  $; zonal mean differences maps
;        /NO_ZONALCONC,  $; zonal tracer concentrations maps
;        /NO_CLOUDDIFF,  $; difference plots of cloud optical depth
;        /NO_2D_MET,     $; difference plots for 2-D met fields
;        /NO_3D_MET,     $; difference plots for 3-D met fields
;        /NO_FULLCHEM,   $; enable if chemistry is turned off
;         _EXTRA = e

   ; Create PDF files from the postscript files
   Make_Pdf, './'
 
   ; Remove PS files and only keep PDF files
   Spawn, 'rm -v *.ps'

   ; Move emission plots into appropriate folder
   Spawn, 'mv -v *_emission_differences.pdf ./emission_differences/'
   Spawn, 'mv -v *_emission_maps.pdf ./emission_maps/'
   Spawn, 'mv -v *_emission_ratios.pdf ./emission_ratios/'

end
