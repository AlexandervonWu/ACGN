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

pred cap004585 { not ((inv2 and ((some capBenchS or no CapBenchA) or some CapBenchB)) and ((no CapBenchA and some CapBenchA) and some capBenchR)) }
pred cap004585c { ((not ((no CapBenchA and some CapBenchA) and some capBenchR)) or (not (inv2 and ((some capBenchS or no CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004585 { cap004585 iff cap004585c }
check CapBenchEquivalent_cap004585 for 4
