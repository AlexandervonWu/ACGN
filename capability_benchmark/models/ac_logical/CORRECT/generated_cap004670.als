sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004670 { not ((inv5 and ((no CapBenchA and some capBenchS) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) }
pred cap004670c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) or (not (inv5 and ((no CapBenchA and some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004670 { cap004670 iff cap004670c }
check CapBenchEquivalent_cap004670 for 4
