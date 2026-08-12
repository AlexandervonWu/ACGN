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

pred cap003325 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or some capBenchS)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003325c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003325 { cap003325 iff cap003325c }
check CapBenchEquivalent_cap003325 for 4
