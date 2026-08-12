sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002162 { not not ((inv8 and ((no CapBenchA and some capBenchR) and no CapBenchA))) }
pred cap002162c { (inv8 and ((no CapBenchA and some capBenchR) and no CapBenchA)) }
assert CapBenchEquivalent_cap002162 { cap002162 iff cap002162c }
check CapBenchEquivalent_cap002162 for 4
