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

pred cap004041 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
pred cap004041c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap004041 { cap004041 iff cap004041c }
check CapBenchEquivalent_cap004041 for 4
