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

pred cap002100 { not (all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or some CapBenchB)))) }
pred cap002100c { some x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap002100 { cap002100 iff cap002100c }
check CapBenchEquivalent_cap002100 for 4
