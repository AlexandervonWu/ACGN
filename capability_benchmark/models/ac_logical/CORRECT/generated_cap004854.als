sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004854 { not ((inv3 and ((no CapBenchA and some capBenchR) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) }
pred cap004854c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) or (not (inv3 and ((no CapBenchA and some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap004854 { cap004854 iff cap004854c }
check CapBenchEquivalent_cap004854 for 4
