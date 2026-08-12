sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap001235 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap001235c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap001235 { cap001235 iff cap001235c }
check CapBenchEquivalent_cap001235 for 4
