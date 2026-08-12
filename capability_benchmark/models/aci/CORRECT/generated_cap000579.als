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

pred cap000579 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB)) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB) or ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000579c { (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB) or ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000579 { cap000579 iff cap000579c }
check CapBenchEquivalent_cap000579 for 4
