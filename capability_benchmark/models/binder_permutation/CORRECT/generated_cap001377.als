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

pred cap001377 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap001377c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap001377 { cap001377 iff cap001377c }
check CapBenchEquivalent_cap001377 for 4
