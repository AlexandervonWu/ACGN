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

pred cap002131 { no x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap002131c { all x: CapBenchA | not (x->x in capBenchR and (inv4 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002131 { cap002131 iff cap002131c }
check CapBenchEquivalent_cap002131 for 4
