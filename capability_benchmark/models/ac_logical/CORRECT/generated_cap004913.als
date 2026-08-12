sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
all f:File | f in Trash
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

pred cap004913 { not ((inv2 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some CapBenchB) and some CapBenchB)) }
pred cap004913c { ((not ((no CapBenchA and some CapBenchB) and some CapBenchB)) or (not (inv2 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004913 { cap004913 iff cap004913c }
check CapBenchEquivalent_cap004913 for 4
