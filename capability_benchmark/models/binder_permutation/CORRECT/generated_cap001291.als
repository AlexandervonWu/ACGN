sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001291 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv5 and ((no CapBenchB or some capBenchR) and some capBenchR))) }
pred cap001291c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv5 and ((no CapBenchB or some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap001291 { cap001291 iff cap001291c }
check CapBenchEquivalent_cap001291 for 4
