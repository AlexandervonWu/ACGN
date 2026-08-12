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

pred cap004901 { not ((inv2 and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap004901c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) or (not (inv2 and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004901 { cap004901 iff cap004901c }
check CapBenchEquivalent_cap004901 for 4
