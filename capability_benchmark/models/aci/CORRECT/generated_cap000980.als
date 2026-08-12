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

pred cap000980 { ((inv3 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some CapBenchB) or no CapBenchA) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap000980c { (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR) and (inv3 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some CapBenchB) or no CapBenchA)) }
assert CapBenchEquivalent_cap000980 { cap000980 iff cap000980c }
check CapBenchEquivalent_cap000980 for 4
