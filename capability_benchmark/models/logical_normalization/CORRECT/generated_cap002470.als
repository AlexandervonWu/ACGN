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

pred cap002470 { ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) implies ((no CapBenchB or some CapBenchA) and no CapBenchA)) }
pred cap002470c { ((not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) or ((no CapBenchB or some CapBenchA) and no CapBenchA)) }
assert CapBenchEquivalent_cap002470 { cap002470 iff cap002470c }
check CapBenchEquivalent_cap002470 for 4
