sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004460 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004460c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004460 { cap004460 iff cap004460c }
check CapBenchEquivalent_cap004460 for 4
