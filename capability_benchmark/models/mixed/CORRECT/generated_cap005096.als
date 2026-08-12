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

pred cap005096 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some CapBenchA and some capBenchR) or some CapBenchB)) and ((some capBenchS or some CapBenchB) or some capBenchR))) }
pred cap005096c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchB) or some capBenchR)) or (not (inv9 and ((some CapBenchA and some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005096 { cap005096 iff cap005096c }
check CapBenchEquivalent_cap005096 for 4
