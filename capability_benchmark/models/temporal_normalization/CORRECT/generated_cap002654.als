sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all p : Protected | p  not in Trash
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

pred cap002654 { not (((inv4 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) until (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap002654c { ((not (inv4 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) releases (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002654 { cap002654 iff cap002654c }
check CapBenchEquivalent_cap002654 for 4
