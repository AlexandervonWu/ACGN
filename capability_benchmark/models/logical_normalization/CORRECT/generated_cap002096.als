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

pred cap002096 { not not ((inv4 and ((some CapBenchA and some capBenchR) or some CapBenchB))) }
pred cap002096c { (inv4 and ((some CapBenchA and some capBenchR) or some CapBenchB)) }
assert CapBenchEquivalent_cap002096 { cap002096 iff cap002096c }
check CapBenchEquivalent_cap002096 for 4
