sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f:Protected | f not in Trash
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

pred cap003838 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
pred cap003838c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003838 { cap003838 iff cap003838c }
check CapBenchEquivalent_cap003838 for 4
