sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
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

pred cap000854 { ((inv4 and ((no CapBenchA and some capBenchR) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap000854c { (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA) and (inv4 and ((no CapBenchA and some capBenchR) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) }
assert CapBenchEquivalent_cap000854 { cap000854 iff cap000854c }
check CapBenchEquivalent_cap000854 for 4
