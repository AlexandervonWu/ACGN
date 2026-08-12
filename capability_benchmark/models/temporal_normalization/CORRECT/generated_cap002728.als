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

pred cap002728 { not always ((inv9 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
pred cap002728c { eventually (not (inv9 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap002728 { cap002728 iff cap002728c }
check CapBenchEquivalent_cap002728 for 4
