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

pred cap000902 { ((inv4 and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA) and ((some capBenchS or some capBenchS) or no CapBenchB)) }
pred cap000902c { (((some capBenchS or some capBenchS) or no CapBenchB) and (inv4 and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
assert CapBenchEquivalent_cap000902 { cap000902 iff cap000902c }
check CapBenchEquivalent_cap000902 for 4
