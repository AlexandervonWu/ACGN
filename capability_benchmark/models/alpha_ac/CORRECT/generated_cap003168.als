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

pred cap003168 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchA)) and ((some capBenchS or no CapBenchA) or some capBenchS)) }
pred cap003168c { all renamed: CapBenchA | (((some capBenchS or no CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap003168 { cap003168 iff cap003168c }
check CapBenchEquivalent_cap003168 for 4
