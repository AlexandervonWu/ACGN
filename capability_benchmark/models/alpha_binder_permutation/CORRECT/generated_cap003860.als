sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap003860 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchA and some capBenchS) or some capBenchS))) }
pred cap003860c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some CapBenchA and some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap003860 { cap003860 iff cap003860c }
check CapBenchEquivalent_cap003860 for 4
