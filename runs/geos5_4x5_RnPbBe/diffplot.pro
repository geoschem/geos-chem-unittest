pro diffplot, DiagN, Print = Print, _EXTRA = e

   ;%%%%% QUICKIE PROGRAM TO MAKE DIFFERNCE PLOTS %%%%%
   ;%%%%% FROM DIFFERENCE TEST OUTPUT FILES       %%%%%

   ; Files
   File1 = './trac_avg.geos5_4x5_RnPbBe.2005070100.sp'
   File2 = './trac_avg.geos5_4x5_RnPbBe.2005070100.mp' 

   ; Time
   Tau = [ Nymd2Tau( 20120701 ) ]

   ; Clean up old files for safety's sake
   ctm_cleanup

   ; Print or plot?
   if ( Keyword_Set( Print ) ) then begin
      
      ; Print differences w/o plotting
      CTM_PrintDiff, DiagN,  File1=File1, File2=File2, $
                     /Quiet, /NoPrint,    Tau0=Tau0,  _EXTRA=e   
   endif else begin

      ; Plot the differences
      CTM_PlotDiff4,  DiagN, File1, File2, Tau0=Tau0, _EXTRA=e

   endelse

end
