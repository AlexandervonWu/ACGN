sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000085 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or no CapBenchA) or some CapBenchB))) }
pred cap000085c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some capBenchS or no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000085 { cap000085 iff cap000085c }
check CapBenchEquivalent_cap000085 for 4
