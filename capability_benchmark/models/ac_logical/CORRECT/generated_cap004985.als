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

pred cap004985 { not ((inv3 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and no CapBenchA) and no CapBenchA)) }
pred cap004985c { ((not ((no CapBenchA and no CapBenchA) and no CapBenchA)) or (not (inv3 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004985 { cap004985 iff cap004985c }
check CapBenchEquivalent_cap004985 for 4
