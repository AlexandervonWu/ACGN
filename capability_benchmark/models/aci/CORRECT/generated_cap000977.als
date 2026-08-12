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

pred cap000977 { (inv4 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000977c { ((inv4 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (inv4 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000977 { cap000977 iff cap000977c }
check CapBenchEquivalent_cap000977 for 4
