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

pred cap004867 { not ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)) and ((some capBenchR and no CapBenchB) or some CapBenchA)) }
pred cap004867c { ((not ((some capBenchR and no CapBenchB) or some CapBenchA)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap004867 { cap004867 iff cap004867c }
check CapBenchEquivalent_cap004867 for 4
