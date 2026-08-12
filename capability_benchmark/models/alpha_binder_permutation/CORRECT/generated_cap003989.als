sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003989 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap003989c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003989 { cap003989 iff cap003989c }
check CapBenchEquivalent_cap003989 for 4
