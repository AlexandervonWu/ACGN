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

pred cap001456 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001456c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001456 { cap001456 iff cap001456c }
check CapBenchEquivalent_cap001456 for 4
