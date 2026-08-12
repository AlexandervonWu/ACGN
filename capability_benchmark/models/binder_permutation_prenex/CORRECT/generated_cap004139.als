sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004139 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap004139c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap004139 { cap004139 iff cap004139c }
check CapBenchEquivalent_cap004139 for 4
