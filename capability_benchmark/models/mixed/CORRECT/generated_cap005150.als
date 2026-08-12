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

pred cap005150 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap005150c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchA) and some capBenchS)) or (not (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005150 { cap005150 iff cap005150c }
check CapBenchEquivalent_cap005150 for 4
