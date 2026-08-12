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

pred cap001908 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001908c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001908 { cap001908 iff cap001908c }
check CapBenchEquivalent_cap001908 for 4
