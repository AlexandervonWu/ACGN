sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f:Protected | f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004896 { not ((inv4 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap004896c { ((not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or (not (inv4 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004896 { cap004896 iff cap004896c }
check CapBenchEquivalent_cap004896 for 4
