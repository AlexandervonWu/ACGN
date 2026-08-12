sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
all f,g,h:File | f->g in link implies g->h not in link
}

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001323 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv9 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap001323c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv9 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap001323 { cap001323 iff cap001323c }
check CapBenchEquivalent_cap001323 for 4
