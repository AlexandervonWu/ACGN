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

pred cap002488 { ((inv1 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) implies ((some capBenchS or no CapBenchA) or no CapBenchA)) }
pred cap002488c { ((not (inv1 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) or ((some capBenchS or no CapBenchA) or no CapBenchA)) }
assert CapBenchEquivalent_cap002488 { cap002488 iff cap002488c }
check CapBenchEquivalent_cap002488 for 4
