sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap004968 { not ((inv3 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchA) or no CapBenchA)) }
pred cap004968c { ((not ((some CapBenchB or some CapBenchA) or no CapBenchA)) or (not (inv3 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004968 { cap004968 iff cap004968c }
check CapBenchEquivalent_cap004968 for 4
