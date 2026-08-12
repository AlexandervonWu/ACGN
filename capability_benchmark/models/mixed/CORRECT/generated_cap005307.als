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

pred cap005307 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005307c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)))) }
assert CapBenchEquivalent_cap005307 { cap005307 iff cap005307c }
check CapBenchEquivalent_cap005307 for 4
