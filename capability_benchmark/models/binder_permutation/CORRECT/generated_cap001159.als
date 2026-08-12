sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001159 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap001159c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap001159 { cap001159 iff cap001159c }
check CapBenchEquivalent_cap001159 for 4
