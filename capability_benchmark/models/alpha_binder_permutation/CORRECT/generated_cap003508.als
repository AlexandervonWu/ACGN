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

pred cap003508 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
pred cap003508c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003508 { cap003508 iff cap003508c }
check CapBenchEquivalent_cap003508 for 4
