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

pred cap005066 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchA and some CapBenchA) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap005066c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB)) or (not (inv3 and ((no CapBenchA and some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005066 { cap005066 iff cap005066c }
check CapBenchEquivalent_cap005066 for 4
