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

pred cap003104 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some capBenchS) or some CapBenchB)) and ((some capBenchS or no CapBenchA) or some capBenchR)) }
pred cap003104c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap003104 { cap003104 iff cap003104c }
check CapBenchEquivalent_cap003104 for 4
