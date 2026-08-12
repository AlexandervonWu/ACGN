sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002056 { ((inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) implies ((some capBenchS or some capBenchR) or no CapBenchB)) }
pred cap002056c { ((not (inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) or ((some capBenchS or some capBenchR) or no CapBenchB)) }
assert CapBenchEquivalent_cap002056 { cap002056 iff cap002056c }
check CapBenchEquivalent_cap002056 for 4
