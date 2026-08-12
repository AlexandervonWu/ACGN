sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
all f:File | f in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002690 { not (((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) until (((no CapBenchB or some capBenchS) and some capBenchS))) }
pred cap002690c { ((not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) releases (not ((no CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap002690 { cap002690 iff cap002690c }
check CapBenchEquivalent_cap002690 for 4
