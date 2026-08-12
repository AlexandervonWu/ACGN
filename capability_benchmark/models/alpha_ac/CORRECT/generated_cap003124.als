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

pred cap003124 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some CapBenchB or some capBenchS) or some capBenchR)) }
pred cap003124c { all renamed: CapBenchA | (((some CapBenchB or some capBenchS) or some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003124 { cap003124 iff cap003124c }
check CapBenchEquivalent_cap003124 for 4
