sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000952 { (inv4 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000952c { ((inv4 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and (inv4 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000952 { cap000952 iff cap000952c }
check CapBenchEquivalent_cap000952 for 4
