sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000167 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap000167c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap000167 { cap000167 iff cap000167c }
check CapBenchEquivalent_cap000167 for 4
