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

pred cap004940 { not ((inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some capBenchR) or some CapBenchB)) }
pred cap004940c { ((not ((some capBenchS or some capBenchR) or some CapBenchB)) or (not (inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004940 { cap004940 iff cap004940c }
check CapBenchEquivalent_cap004940 for 4
