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

pred cap001957 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001957c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001957 { cap001957 iff cap001957c }
check CapBenchEquivalent_cap001957 for 4
