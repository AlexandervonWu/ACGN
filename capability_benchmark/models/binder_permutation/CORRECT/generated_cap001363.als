sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no (link.Trash)
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001363 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv7 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
pred cap001363c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv7 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap001363 { cap001363 iff cap001363c }
check CapBenchEquivalent_cap001363 for 4
