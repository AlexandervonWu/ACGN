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

pred cap002303 { ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) iff ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002303c { (((not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) or ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((not ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap002303 { cap002303 iff cap002303c }
check CapBenchEquivalent_cap002303 for 4
