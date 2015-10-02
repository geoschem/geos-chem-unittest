pro diffplot, DiagN, Print = Print, _EXTRA = e

   ;%%%%% QUICKIE PROGRAM TO MAKE DIFFERNCE PLOTS %%%%%
   ;%%%%% FROM DIFFERENCE TEST OUTPUT FILES       %%%%%

   ; Files
   File1 = Expand_Path( '../Ref/trac_avg.2012070100.Ref' )  ; Ref code
   File2 = Expand_Path( './trac_avg.2012070100.Dev'      )  ; Def code

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
