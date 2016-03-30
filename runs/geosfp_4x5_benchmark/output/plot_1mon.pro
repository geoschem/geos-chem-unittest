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

   ; To generate only tracer concentration maps
   ;Benchmark_1Mon, InFile, /No_Profiles, /NO_BUDGET, /NO_EMISSIONS, $
   ;    /NO_FREQ_DIST, /NO_DIFFS, /NO_JVALUES, /NO_RATIOS,  /NO_ZONALDiff, $
   ;    /No_2D_Met, /No_3D_Met, /NO_JVDIFFS, /No_AOD_Diffs, /No_AOD_Maps, $
   ;    /No_JVMaps, /No_StratDiff, /No_CloudDiff, _EXTRA=e

   ; To generate only zonal maps
   ;Benchmark_1Mon, InFile, /No_Profiles, /NO_BUDGET, /NO_EMISSIONS, $
   ;    /NO_FREQ_DIST, /NO_DIFFS, /NO_JVALUES, /NO_RATIOS, /No_Conc_Maps,  $
   ;    /No_2D_Met, /No_3D_Met, /NO_JVDIFFS, /No_AOD_Diffs, /No_AOD_Maps, $
   ;    /No_JVMaps, /No_CloudDiff, _EXTRA=e

   ; To generate only J-values maps
   ;Benchmark_1Mon, InFile, /No_Profiles, /NO_BUDGET, /NO_EMISSIONS, $
   ;    /NO_FREQ_DIST, /NO_DIFFS, /NO_RATIOS,  /NO_ZONALDiff, $
   ;    /NO_ZONALCONC, /No_2D_Met, /No_3D_Met, /No_Conc_Maps, $
   ;    /No_AOD_Maps, /No_AOD_Diffs, /No_StratDiff, /No_StratConc, $
   ;    /No_CloudDiff, _EXTRA=e

   ; To generate only emission maps
   ;Benchmark_1Mon, InFile, /No_Profiles, /NO_BUDGET, $
   ;    /NO_FREQ_DIST, /NO_DIFFS, /NO_JVALUES, /NO_RATIOS,  /NO_ZONALDiff, $
   ;    /No_2D_Met, /No_3D_Met, /NO_JVDIFFS, /No_AOD_Diffs, /No_AOD_Maps, $
   ;    /No_JVMaps, /No_Conc_Maps, /NO_ZONALCONC, /No_StratDiff, $
   ;    /No_StratConc, /No_CloudDiff, _EXTRA=e

   ; To generate only budget
   ;Benchmark_1Mon, InFile, /No_Profiles, /NO_EMISSIONS, $
   ;    /NO_FREQ_DIST, /NO_DIFFS, /NO_JVALUES, /NO_RATIOS,  /NO_ZONALDiff, $
   ;    /No_2D_Met, /No_3D_Met, /NO_JVDIFFS, /No_AOD_Diffs, /No_AOD_Maps, $
   ;    /No_JVMaps, /No_Conc_Maps, /NO_ZONALCONC, /No_StratDiff, $
   ;    /No_StratConc, /No_CloudDiff, _EXTRA=e

   ; Create PDF files from the postscript files
   Make_Pdf, './'
 
   ; Remove PS files and only keep PDF files
   Spawn, 'rm -v *.ps'

   ; Move emission plots into appropriate folder
   Spawn, 'mv -v *_emission_differences.pdf ./emission_differences/'
   Spawn, 'mv -v *_emission_maps.pdf ./emission_maps/'
   Spawn, 'mv -v *_emission_ratios.pdf ./emission_ratios/'

end
