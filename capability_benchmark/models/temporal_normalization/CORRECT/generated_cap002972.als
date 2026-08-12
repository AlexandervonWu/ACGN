sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
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

pred cap002972 { not (((inv8 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) until (((some capBenchS or some CapBenchA) or no CapBenchA))) }
pred cap002972c { ((not (inv8 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) releases (not ((some capBenchS or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002972 { cap002972 iff cap002972c }
check CapBenchEquivalent_cap002972 for 4
