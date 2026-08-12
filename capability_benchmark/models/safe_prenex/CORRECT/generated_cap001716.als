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

pred cap001716 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
pred cap001716c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001716 { cap001716 iff cap001716c }
check CapBenchEquivalent_cap001716 for 4
