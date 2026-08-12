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

pred cap005376 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((some capBenchS or some capBenchR) or some CapBenchA))) }
pred cap005376c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchR) or some CapBenchA)) or (not (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005376 { cap005376 iff cap005376c }
check CapBenchEquivalent_cap005376 for 4
