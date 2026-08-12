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

pred cap001518 { ((some x: CapBenchA | x->x in capBenchR) and (inv9 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap001518c { (some x: CapBenchA | (x->x in capBenchR and (inv9 and ((no CapBenchA and no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001518 { cap001518 iff cap001518c }
check CapBenchEquivalent_cap001518 for 4
