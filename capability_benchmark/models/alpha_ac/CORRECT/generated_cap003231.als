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

pred cap003231 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003231c { all renamed: CapBenchA | (((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap003231 { cap003231 iff cap003231c }
check CapBenchEquivalent_cap003231 for 4
