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

pred cap005348 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchR and no CapBenchB) or some capBenchS)) and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
pred cap005348c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or some CapBenchA)) or (not (inv1 and ((some capBenchR and no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005348 { cap005348 iff cap005348c }
check CapBenchEquivalent_cap005348 for 4
