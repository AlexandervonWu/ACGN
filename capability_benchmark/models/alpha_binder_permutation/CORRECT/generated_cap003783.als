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

pred cap003783 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap003783c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003783 { cap003783 iff cap003783c }
check CapBenchEquivalent_cap003783 for 4
