sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002539 { not once ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap002539c { historically (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap002539 { cap002539 iff cap002539c }
check CapBenchEquivalent_cap002539 for 4
