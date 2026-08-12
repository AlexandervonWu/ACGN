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

pred cap004672 { not ((inv4 and ((some capBenchR and some capBenchS) or no CapBenchA)) and ((some CapBenchB or no CapBenchB) or some capBenchS)) }
pred cap004672c { ((not ((some CapBenchB or no CapBenchB) or some capBenchS)) or (not (inv4 and ((some capBenchR and some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004672 { cap004672 iff cap004672c }
check CapBenchEquivalent_cap004672 for 4
