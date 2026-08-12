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

pred cap001452 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001452c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001452 { cap001452 iff cap001452c }
check CapBenchEquivalent_cap001452 for 4
