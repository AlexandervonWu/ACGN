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

pred cap003170 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) }
pred cap003170c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap003170 { cap003170 iff cap003170c }
check CapBenchEquivalent_cap003170 for 4
