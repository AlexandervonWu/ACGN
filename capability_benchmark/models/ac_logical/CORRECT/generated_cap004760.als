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

pred cap004760 { not ((inv2 and ((some capBenchR and some CapBenchA) or some capBenchR)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004760c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((some capBenchR and some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap004760 { cap004760 iff cap004760c }
check CapBenchEquivalent_cap004760 for 4
