sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001624 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap001624c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001624 { cap001624 iff cap001624c }
check CapBenchEquivalent_cap001624 for 4
