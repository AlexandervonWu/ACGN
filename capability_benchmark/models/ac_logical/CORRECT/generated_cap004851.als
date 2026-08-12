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

pred cap004851 { not ((inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) and ((some capBenchR and some CapBenchB) or some CapBenchA)) }
pred cap004851c { ((not ((some capBenchR and some CapBenchB) or some CapBenchA)) or (not (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004851 { cap004851 iff cap004851c }
check CapBenchEquivalent_cap004851 for 4
