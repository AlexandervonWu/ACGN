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

pred cap002121 { not ((inv9 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) }
pred cap002121c { ((not (inv9 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap002121 { cap002121 iff cap002121c }
check CapBenchEquivalent_cap002121 for 4
