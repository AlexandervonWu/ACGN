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

pred cap003377 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) }
pred cap003377c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003377 { cap003377 iff cap003377c }
check CapBenchEquivalent_cap003377 for 4
