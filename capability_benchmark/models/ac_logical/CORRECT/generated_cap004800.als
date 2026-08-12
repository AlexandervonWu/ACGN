sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
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

pred cap004800 { not ((inv3 and ((some capBenchR and some capBenchS) or some capBenchR)) and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004800c { ((not ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some capBenchR and some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap004800 { cap004800 iff cap004800c }
check CapBenchEquivalent_cap004800 for 4
