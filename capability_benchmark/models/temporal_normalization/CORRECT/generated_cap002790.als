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

pred cap002790 { not historically ((inv9 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
pred cap002790c { once (not (inv9 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap002790 { cap002790 iff cap002790c }
check CapBenchEquivalent_cap002790 for 4
