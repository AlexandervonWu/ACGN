sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all p : Protected | p  not in Trash
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

pred cap004786 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)) and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004786c { ((not ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004786 { cap004786 iff cap004786c }
check CapBenchEquivalent_cap004786 for 4
