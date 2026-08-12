sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003839 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap003839c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003839 { cap003839 iff cap003839c }
check CapBenchEquivalent_cap003839 for 4
