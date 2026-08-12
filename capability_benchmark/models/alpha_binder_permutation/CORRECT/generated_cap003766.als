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

pred cap003766 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
pred cap003766c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003766 { cap003766 iff cap003766c }
check CapBenchEquivalent_cap003766 for 4
