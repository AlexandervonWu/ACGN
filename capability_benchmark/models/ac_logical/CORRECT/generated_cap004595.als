sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File | f not in Protected implies f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004595 { not ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)) and ((some capBenchR and some CapBenchB) or some capBenchR)) }
pred cap004595c { ((not ((some capBenchR and some CapBenchB) or some capBenchR)) or (not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004595 { cap004595 iff cap004595c }
check CapBenchEquivalent_cap004595 for 4
