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

pred cap001100 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
pred cap001100c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap001100 { cap001100 iff cap001100c }
check CapBenchEquivalent_cap001100 for 4
