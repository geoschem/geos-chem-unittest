pro diff, bpch = bpch, _EXTRA = e

   ; %%% THIS IS A WRAPPER FOR CTM_LOCATEDIFF %%%

   if ( Keyword_Set( Bpch ) ) then begin
      f1 =  'trac_avg.geos5_4x5_UCX.2005070100.sp'
      f2 =  'trac_avg.geos5_4x5_UCX.2005070100.mp'
   endif else begin
      f1 =  'trac_rst.geos5_4x5_UCX.2005070101.sp'
      f2 =  'trac_rst.geos5_4x5_UCX.2005070101.mp'
   endelse

   ; Call CTM_LOCATEDIFF
   ctm_locatediff, f1, f2, _EXTRA = e

end
