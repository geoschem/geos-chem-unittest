pro diff, _EXTRA = e

   ; %%%%% Wrapper program; calls CTM_LOCATEDIFF %%%%%

   ; Files
   File1 = '../Ref/trac_avg.201307010000.Ref'
   File2 = './trac_avg.201307010000.Dev'

   ; Look for differences
   CTM_LocateDiff, File1, File2, _EXTRA = e
end
