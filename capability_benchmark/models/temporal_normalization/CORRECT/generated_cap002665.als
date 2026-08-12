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

pred cap002665 { not once ((inv4 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
pred cap002665c { historically (not (inv4 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap002665 { cap002665 iff cap002665c }
check CapBenchEquivalent_cap002665 for 4
