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

pred cap002396 { not not ((inv8 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002396c { (inv8 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002396 { cap002396 iff cap002396c }
check CapBenchEquivalent_cap002396 for 4
