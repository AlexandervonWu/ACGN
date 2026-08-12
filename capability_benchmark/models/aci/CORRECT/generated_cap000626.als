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

pred cap000626 { ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((no CapBenchB or some capBenchS) and some capBenchR) and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000626c { (((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((no CapBenchB or some capBenchS) and some capBenchR)) }
assert CapBenchEquivalent_cap000626 { cap000626 iff cap000626c }
check CapBenchEquivalent_cap000626 for 4
