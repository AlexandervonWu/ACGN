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

pred cap000791 { (inv2 and ((no CapBenchB or some capBenchR) and some capBenchR)) }
pred cap000791c { ((inv2 and ((no CapBenchB or some capBenchR) and some capBenchR)) or (inv2 and ((no CapBenchB or some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap000791 { cap000791 iff cap000791c }
check CapBenchEquivalent_cap000791 for 4
