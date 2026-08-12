sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001295 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) }
pred cap001295c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap001295 { cap001295 iff cap001295c }
check CapBenchEquivalent_cap001295 for 4
