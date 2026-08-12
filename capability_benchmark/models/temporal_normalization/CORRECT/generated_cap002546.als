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

pred cap002546 { not (((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) until (((no CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap002546c { ((not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) releases (not ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002546 { cap002546 iff cap002546c }
check CapBenchEquivalent_cap002546 for 4
