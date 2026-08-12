sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap005043 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchB or some capBenchS) and some CapBenchA)) and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
pred cap005043c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchB) or no CapBenchB)) or (not (inv3 and ((no CapBenchB or some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005043 { cap005043 iff cap005043c }
check CapBenchEquivalent_cap005043 for 4
