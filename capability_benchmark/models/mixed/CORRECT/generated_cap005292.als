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

pred cap005292 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and some capBenchR) or some capBenchR)) and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005292c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv5 and ((some capBenchR and some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap005292 { cap005292 iff cap005292c }
check CapBenchEquivalent_cap005292 for 4
