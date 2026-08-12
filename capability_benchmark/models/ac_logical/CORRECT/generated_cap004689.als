sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004689 { not ((inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((no CapBenchA and some capBenchS) and some capBenchS)) }
pred cap004689c { ((not ((no CapBenchA and some capBenchS) and some capBenchS)) or (not (inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004689 { cap004689 iff cap004689c }
check CapBenchEquivalent_cap004689 for 4
