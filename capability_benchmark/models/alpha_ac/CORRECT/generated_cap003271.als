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

pred cap003271 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003271c { all renamed: CapBenchA | (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003271 { cap003271 iff cap003271c }
check CapBenchEquivalent_cap003271 for 4
