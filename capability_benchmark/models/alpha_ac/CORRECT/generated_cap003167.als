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

pred cap003167 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA)) and ((some capBenchR and no CapBenchA) or some capBenchS)) }
pred cap003167c { all renamed: CapBenchA | (((some capBenchR and no CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003167 { cap003167 iff cap003167c }
check CapBenchEquivalent_cap003167 for 4
