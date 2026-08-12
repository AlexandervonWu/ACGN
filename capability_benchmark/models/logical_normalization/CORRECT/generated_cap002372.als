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

pred cap002372 { not not ((inv2 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap002372c { (inv2 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
assert CapBenchEquivalent_cap002372 { cap002372 iff cap002372c }
check CapBenchEquivalent_cap002372 for 4
