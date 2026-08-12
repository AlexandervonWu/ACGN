sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
all f:File | f in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001690 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap001690c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001690 { cap001690 iff cap001690c }
check CapBenchEquivalent_cap001690 for 4
