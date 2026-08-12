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

pred cap002156 { not not ((inv4 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
pred cap002156c { (inv4 and ((some capBenchR and no CapBenchB) or no CapBenchA)) }
assert CapBenchEquivalent_cap002156 { cap002156 iff cap002156c }
check CapBenchEquivalent_cap002156 for 4
