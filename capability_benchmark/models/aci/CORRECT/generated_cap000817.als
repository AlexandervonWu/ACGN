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

pred cap000817 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap000817c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000817 { cap000817 iff cap000817c }
check CapBenchEquivalent_cap000817 for 4
