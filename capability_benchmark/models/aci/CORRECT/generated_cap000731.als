sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000731 { (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) }
pred cap000731c { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap000731 { cap000731 iff cap000731c }
check CapBenchEquivalent_cap000731 for 4
