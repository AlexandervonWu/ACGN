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

pred cap003367 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)) and ((some capBenchR and no CapBenchB) or some CapBenchA)) }
pred cap003367c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap003367 { cap003367 iff cap003367c }
check CapBenchEquivalent_cap003367 for 4
