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

pred cap004196 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
pred cap004196c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap004196 { cap004196 iff cap004196c }
check CapBenchEquivalent_cap004196 for 4
