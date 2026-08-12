sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
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

pred cap000297 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
pred cap000297c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap000297 { cap000297 iff cap000297c }
check CapBenchEquivalent_cap000297 for 4
