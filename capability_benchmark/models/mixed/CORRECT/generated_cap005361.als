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

pred cap005361 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchB or some capBenchS) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
pred cap005361c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) or (not (inv3 and ((some CapBenchB or some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap005361 { cap005361 iff cap005361c }
check CapBenchEquivalent_cap005361 for 4
