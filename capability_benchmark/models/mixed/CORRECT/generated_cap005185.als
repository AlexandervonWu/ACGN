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

pred cap005185 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
pred cap005185c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)) or (not (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005185 { cap005185 iff cap005185c }
check CapBenchEquivalent_cap005185 for 4
