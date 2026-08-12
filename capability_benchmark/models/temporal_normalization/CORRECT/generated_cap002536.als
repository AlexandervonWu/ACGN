sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002536 { not always ((inv3 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
pred cap002536c { eventually (not (inv3 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap002536 { cap002536 iff cap002536c }
check CapBenchEquivalent_cap002536 for 4
