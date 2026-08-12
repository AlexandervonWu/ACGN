sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000644 { ((inv8 and ((some CapBenchA and no CapBenchA) or no CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR) and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000644c { (((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB) and (inv8 and ((some CapBenchA and no CapBenchA) or no CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
assert CapBenchEquivalent_cap000644 { cap000644 iff cap000644c }
check CapBenchEquivalent_cap000644 for 4
