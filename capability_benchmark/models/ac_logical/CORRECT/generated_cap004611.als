sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f:Protected | f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004611 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) and ((some capBenchR and no CapBenchB) or some capBenchR)) }
pred cap004611c { ((not ((some capBenchR and no CapBenchB) or some capBenchR)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004611 { cap004611 iff cap004611c }
check CapBenchEquivalent_cap004611 for 4
