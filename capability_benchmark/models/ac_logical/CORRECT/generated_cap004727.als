sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
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

pred cap004727 { not ((inv4 and ((no CapBenchB or some capBenchR) and no CapBenchB)) and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004727c { ((not ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv4 and ((no CapBenchB or some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004727 { cap004727 iff cap004727c }
check CapBenchEquivalent_cap004727 for 4
