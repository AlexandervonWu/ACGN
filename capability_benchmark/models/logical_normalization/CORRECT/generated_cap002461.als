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

pred cap002461 { no x: CapBenchA | (x->x in capBenchR and (inv9 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002461c { all x: CapBenchA | not (x->x in capBenchR and (inv9 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002461 { cap002461 iff cap002461c }
check CapBenchEquivalent_cap002461 for 4
