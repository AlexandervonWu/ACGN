sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
all f:File | f not in Trash
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

pred cap002360 { not not ((inv1 and ((some CapBenchA and some capBenchS) or some capBenchS))) }
pred cap002360c { (inv1 and ((some CapBenchA and some capBenchS) or some capBenchS)) }
assert CapBenchEquivalent_cap002360 { cap002360 iff cap002360c }
check CapBenchEquivalent_cap002360 for 4
