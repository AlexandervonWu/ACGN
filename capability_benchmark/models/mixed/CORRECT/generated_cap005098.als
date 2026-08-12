sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005098 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchA and some capBenchR) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap005098c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)) or (not (inv1 and ((no CapBenchA and some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005098 { cap005098 iff cap005098c }
check CapBenchEquivalent_cap005098 for 4
