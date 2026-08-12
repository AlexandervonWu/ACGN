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

pred cap000647 { (inv9 and ((no CapBenchB or no CapBenchA) and no CapBenchA)) }
pred cap000647c { ((inv9 and ((no CapBenchB or no CapBenchA) and no CapBenchA)) or (inv9 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap000647 { cap000647 iff cap000647c }
check CapBenchEquivalent_cap000647 for 4
