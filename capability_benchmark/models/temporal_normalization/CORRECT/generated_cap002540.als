sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002540 { not (((inv8 and ((some CapBenchA and some capBenchS) or some CapBenchA))) until (((some capBenchS or no CapBenchA) or no CapBenchB))) }
pred cap002540c { ((not (inv8 and ((some CapBenchA and some capBenchS) or some CapBenchA))) releases (not ((some capBenchS or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002540 { cap002540 iff cap002540c }
check CapBenchEquivalent_cap002540 for 4
