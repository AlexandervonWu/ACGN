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

pred cap002269 { no x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
pred cap002269c { all x: CapBenchA | not (x->x in capBenchR and (inv8 and ((some capBenchS or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002269 { cap002269 iff cap002269c }
check CapBenchEquivalent_cap002269 for 4
