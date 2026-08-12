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

pred cap000161 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
pred cap000161c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((some CapBenchB or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap000161 { cap000161 iff cap000161c }
check CapBenchEquivalent_cap000161 for 4
