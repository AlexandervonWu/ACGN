sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
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

pred cap002292 { not (all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some capBenchR and some capBenchR) or some capBenchR)))) }
pred cap002292c { some x: CapBenchA | not (x->x in capBenchR and (inv5 and ((some capBenchR and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap002292 { cap002292 iff cap002292c }
check CapBenchEquivalent_cap002292 for 4
