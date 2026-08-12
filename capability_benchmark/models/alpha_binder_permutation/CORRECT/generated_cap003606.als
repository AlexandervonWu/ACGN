sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File in Trash
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

pred cap003606 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some CapBenchB))) }
pred cap003606c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap003606 { cap003606 iff cap003606c }
check CapBenchEquivalent_cap003606 for 4
