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

pred cap000429 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000429c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000429 { cap000429 iff cap000429c }
check CapBenchEquivalent_cap000429 for 4
