sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
all f:File | f in Trash
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

pred cap003109 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or some CapBenchB)) and ((no CapBenchA and no CapBenchB) and some capBenchR)) }
pred cap003109c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap003109 { cap003109 iff cap003109c }
check CapBenchEquivalent_cap003109 for 4
