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

pred cap000701 { (inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchB)) }
pred cap000701c { ((inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchB)) or (inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000701 { cap000701 iff cap000701c }
check CapBenchEquivalent_cap000701 for 4
