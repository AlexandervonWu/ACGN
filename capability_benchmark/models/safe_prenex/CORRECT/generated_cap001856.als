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

pred cap001856 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and some capBenchR) or some capBenchS))) }
pred cap001856c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap001856 { cap001856 iff cap001856c }
check CapBenchEquivalent_cap001856 for 4
