sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File = Trash
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

pred cap001659 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap001659c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001659 { cap001659 iff cap001659c }
check CapBenchEquivalent_cap001659 for 4
