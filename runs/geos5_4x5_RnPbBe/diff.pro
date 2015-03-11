pro diff, _EXTRA = e

   ; %%%%% Wrapper program; calls CTM_LOCATEDIFF %%%%%

   ; Files
   File1 = './trac_avg.geos5_4x5_RnPbBe.2005070100.sp'
   File2 = './trac_avg.geos5_4x5_RnPbBe.2005070100.mp'

   ; Look for differences
   CTM_LocateDiff, File1, File2, _EXTRA = e
end
