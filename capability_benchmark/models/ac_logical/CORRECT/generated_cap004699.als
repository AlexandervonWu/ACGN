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

pred cap004699 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap004699c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004699 { cap004699 iff cap004699c }
check CapBenchEquivalent_cap004699 for 4
