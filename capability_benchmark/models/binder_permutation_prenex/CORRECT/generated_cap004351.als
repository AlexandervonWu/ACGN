sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
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

pred cap004351 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap004351c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap004351 { cap004351 iff cap004351c }
check CapBenchEquivalent_cap004351 for 4
