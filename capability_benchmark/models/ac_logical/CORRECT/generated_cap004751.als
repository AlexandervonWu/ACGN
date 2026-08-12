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

pred cap004751 { not ((inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004751c { ((not ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004751 { cap004751 iff cap004751c }
check CapBenchEquivalent_cap004751 for 4
