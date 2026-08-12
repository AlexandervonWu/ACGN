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

pred cap002827 { not once ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap002827c { historically (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002827 { cap002827 iff cap002827c }
check CapBenchEquivalent_cap002827 for 4
