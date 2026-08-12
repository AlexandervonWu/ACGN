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

pred cap003020 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or some CapBenchA)) and ((some CapBenchB or some CapBenchA) or no CapBenchB)) }
pred cap003020c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003020 { cap003020 iff cap003020c }
check CapBenchEquivalent_cap003020 for 4
