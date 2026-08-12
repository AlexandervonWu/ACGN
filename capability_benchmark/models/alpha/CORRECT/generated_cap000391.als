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

pred cap000391 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000391c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000391 { cap000391 iff cap000391c }
check CapBenchEquivalent_cap000391 for 4
