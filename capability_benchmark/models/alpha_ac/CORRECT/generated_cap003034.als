sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f:Protected | f not in Trash
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

pred cap003034 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) }
pred cap003034c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap003034 { cap003034 iff cap003034c }
check CapBenchEquivalent_cap003034 for 4
