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

pred cap004411 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004411c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004411 { cap004411 iff cap004411c }
check CapBenchEquivalent_cap004411 for 4
