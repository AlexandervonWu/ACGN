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

pred cap000227 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap000227c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((no CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap000227 { cap000227 iff cap000227c }
check CapBenchEquivalent_cap000227 for 4
