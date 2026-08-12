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

pred cap002150 { not not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA))) }
pred cap002150c { (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) }
assert CapBenchEquivalent_cap002150 { cap002150 iff cap002150c }
check CapBenchEquivalent_cap002150 for 4
