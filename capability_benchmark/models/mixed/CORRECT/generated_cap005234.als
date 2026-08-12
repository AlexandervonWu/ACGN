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

pred cap005234 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchA and some capBenchS) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005234c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((no CapBenchA and some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005234 { cap005234 iff cap005234c }
check CapBenchEquivalent_cap005234 for 4
