sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File = Trash
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

pred cap002657 { not eventually ((inv2 and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
pred cap002657c { always (not (inv2 and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002657 { cap002657 iff cap002657c }
check CapBenchEquivalent_cap002657 for 4
