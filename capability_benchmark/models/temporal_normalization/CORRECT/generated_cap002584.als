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

pred cap002584 { not always ((inv3 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
pred cap002584c { eventually (not (inv3 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002584 { cap002584 iff cap002584c }
check CapBenchEquivalent_cap002584 for 4
