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

pred cap003146 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap003146c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003146 { cap003146 iff cap003146c }
check CapBenchEquivalent_cap003146 for 4
