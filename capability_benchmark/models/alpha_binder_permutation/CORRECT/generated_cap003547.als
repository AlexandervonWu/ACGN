sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File = Trash
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

pred cap003547 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap003547c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap003547 { cap003547 iff cap003547c }
check CapBenchEquivalent_cap003547 for 4
