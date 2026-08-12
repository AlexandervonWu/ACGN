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

pred cap004539 { not ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) and ((some capBenchR and no CapBenchA) or no CapBenchB)) }
pred cap004539c { ((not ((some capBenchR and no CapBenchA) or no CapBenchB)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004539 { cap004539 iff cap004539c }
check CapBenchEquivalent_cap004539 for 4
