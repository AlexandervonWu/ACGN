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

pred cap003245 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003245c { all renamed: CapBenchA | (((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap003245 { cap003245 iff cap003245c }
check CapBenchEquivalent_cap003245 for 4
