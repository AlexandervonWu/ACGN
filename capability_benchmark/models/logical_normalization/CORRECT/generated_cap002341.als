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

pred cap002341 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
pred cap002341c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002341 { cap002341 iff cap002341c }
check CapBenchEquivalent_cap002341 for 4
