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

pred cap004482 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004482c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004482 { cap004482 iff cap004482c }
check CapBenchEquivalent_cap004482 for 4
