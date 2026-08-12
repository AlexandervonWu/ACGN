sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003599 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap003599c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003599 { cap003599 iff cap003599c }
check CapBenchEquivalent_cap003599 for 4
