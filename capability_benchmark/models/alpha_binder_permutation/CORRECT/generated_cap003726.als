sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003726 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and no CapBenchB))) }
pred cap003726c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap003726 { cap003726 iff cap003726c }
check CapBenchEquivalent_cap003726 for 4
