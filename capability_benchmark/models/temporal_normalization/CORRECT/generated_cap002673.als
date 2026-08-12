sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002673 { not (((inv5 and ((some capBenchS or some capBenchS) or no CapBenchA))) since (((no CapBenchA and no CapBenchB) and some capBenchS))) }
pred cap002673c { ((not (inv5 and ((some capBenchS or some capBenchS) or no CapBenchA))) triggered (not ((no CapBenchA and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002673 { cap002673 iff cap002673c }
check CapBenchEquivalent_cap002673 for 4
