sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003600 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
pred cap003600c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003600 { cap003600 iff cap003600c }
check CapBenchEquivalent_cap003600 for 4
