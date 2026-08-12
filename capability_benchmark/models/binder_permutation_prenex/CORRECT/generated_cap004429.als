sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004429 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004429c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004429 { cap004429 iff cap004429c }
check CapBenchEquivalent_cap004429 for 4
