s=readLines('~/project/data/dti/dti_ID_trac3_complete.txt')
print(length(s))
Y = data.frame(row.names = s);
m0 = c("fmajor_PP", "fminor_PP", "lh.atr_PP", "rh.atr_PP", "lh.cab_PP", "rh.cab_PP", "lh.ccg_PP", "rh.ccg_PP", 
        "lh.cst_AS", "rh.cst_AS", "lh.ilf_AS", "rh.ilf_AS", "lh.slfp_PP", "rh.slfp_PP", "lh.slft_PP", "rh.slft_PP",
		"lh.unc_AS", "rh.unc_AS")
for(j in 1:length(m0)){
  print(paste(j,"Extracting", m0[j]))
  sj=paste('/ysm-gpfs/home/cm953/scratch60/pnc/dti/',s,'/dpath/', m0[j], '_avg33_mni_bbr/pathstats.overall.txt', sep = '')
  fj=paste('~/project/data/dti/stats/track_files_', m0[j], '.txt', sep = '')
  writeLines(sj, con = fj);
  OJ = paste('~/project/data/dti/stats/dti_stats_', m0[j],'.txt', sep = '')
  IJ = paste('~/project/data/dti/stats/track_files_', m0[j],'.txt', sep = '')
  STR=paste("tractstats2table --load-pathstats-from-file", IJ, "--overall --tablefile", OJ, sep = " ")
  system(STR);
  x = read.table(OJ, header = T, row.names = 1)
  colnames(x) = paste(m0[j], colnames(x), sep = "_")
  o = intersect(rownames(Y), rownames(x));
  Y[, colnames(x)] = NA
  Y[o, colnames(x)] = x[o,]
}
fn_all_stats = "~/project/data/dti/stats/dti_stats_all.txt"
write.table(Y, file = fn_all_stats, row.names = T, col.names = T)
print(paste("Printed to", fn_all_stats))
print(nrow(Y))
