sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
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

pred cap001209 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv8 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
pred cap001209c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv8 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap001209 { cap001209 iff cap001209c }
check CapBenchEquivalent_cap001209 for 4
