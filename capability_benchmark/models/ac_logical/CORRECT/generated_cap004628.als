sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File in Trash
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

pred cap004628 { not ((inv2 and ((some CapBenchA and some CapBenchA) or no CapBenchA)) and ((some capBenchS or some capBenchS) or some capBenchR)) }
pred cap004628c { ((not ((some capBenchS or some capBenchS) or some capBenchR)) or (not (inv2 and ((some CapBenchA and some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004628 { cap004628 iff cap004628c }
check CapBenchEquivalent_cap004628 for 4
