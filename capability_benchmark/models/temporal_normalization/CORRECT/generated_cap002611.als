sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f:Protected | f not in Trash
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

pred cap002611 { not once ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB))) }
pred cap002611c { historically (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap002611 { cap002611 iff cap002611c }
check CapBenchEquivalent_cap002611 for 4
