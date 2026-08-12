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

pred cap001527 { ((all x: CapBenchA | x->x in capBenchR) or (inv9 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap001527c { (all x: CapBenchA | (x->x in capBenchR or (inv9 and ((no CapBenchB or no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001527 { cap001527 iff cap001527c }
check CapBenchEquivalent_cap001527 for 4
