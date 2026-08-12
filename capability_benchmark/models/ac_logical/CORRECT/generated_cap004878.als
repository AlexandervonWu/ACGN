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

pred cap004878 { not ((inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) }
pred cap004878c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) or (not (inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004878 { cap004878 iff cap004878c }
check CapBenchEquivalent_cap004878 for 4
