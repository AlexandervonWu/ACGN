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

pred cap003768 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and some CapBenchB) or some capBenchR))) }
pred cap003768c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some capBenchR and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003768 { cap003768 iff cap003768c }
check CapBenchEquivalent_cap003768 for 4
