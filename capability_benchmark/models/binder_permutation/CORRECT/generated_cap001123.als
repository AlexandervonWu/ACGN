sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001123 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv8 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap001123c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv8 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap001123 { cap001123 iff cap001123c }
check CapBenchEquivalent_cap001123 for 4
