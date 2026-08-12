sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
all f:File | f in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000880 { (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap000880c { ((inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000880 { cap000880 iff cap000880c }
check CapBenchEquivalent_cap000880 for 4
