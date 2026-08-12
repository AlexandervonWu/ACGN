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

pred cap003158 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) and ((no CapBenchB or some CapBenchB) and some capBenchS)) }
pred cap003158c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003158 { cap003158 iff cap003158c }
check CapBenchEquivalent_cap003158 for 4
