sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
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

pred cap003647 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap003647c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((no CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003647 { cap003647 iff cap003647c }
check CapBenchEquivalent_cap003647 for 4
