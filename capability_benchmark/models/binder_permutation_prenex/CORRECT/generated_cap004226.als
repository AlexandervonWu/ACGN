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

pred cap004226 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and some capBenchR) and no CapBenchB))) }
pred cap004226c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap004226 { cap004226 iff cap004226c }
check CapBenchEquivalent_cap004226 for 4
