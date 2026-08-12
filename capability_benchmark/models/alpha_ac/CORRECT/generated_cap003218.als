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

pred cap003218 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003218c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003218 { cap003218 iff cap003218c }
check CapBenchEquivalent_cap003218 for 4
