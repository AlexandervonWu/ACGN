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

pred cap001340 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
pred cap001340c { all a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap001340 { cap001340 iff cap001340c }
check CapBenchEquivalent_cap001340 for 4
