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

pred cap003898 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003898c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003898 { cap003898 iff cap003898c }
check CapBenchEquivalent_cap003898 for 4
