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

pred cap002358 { not (all x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)))) }
pred cap002358c { some x: CapBenchA | not (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap002358 { cap002358 iff cap002358c }
check CapBenchEquivalent_cap002358 for 4
