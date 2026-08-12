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

pred cap001174 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
pred cap001174c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap001174 { cap001174 iff cap001174c }
check CapBenchEquivalent_cap001174 for 4
