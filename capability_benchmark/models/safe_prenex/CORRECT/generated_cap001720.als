sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
all f:File | f not in Trash
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

pred cap001720 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and no CapBenchB) or no CapBenchB))) }
pred cap001720c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001720 { cap001720 iff cap001720c }
check CapBenchEquivalent_cap001720 for 4
