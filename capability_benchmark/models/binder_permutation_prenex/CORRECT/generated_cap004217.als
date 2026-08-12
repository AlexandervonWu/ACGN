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

pred cap004217 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some CapBenchB or no CapBenchB) or no CapBenchB))) }
pred cap004217c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some CapBenchB or no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap004217 { cap004217 iff cap004217c }
check CapBenchEquivalent_cap004217 for 4
