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

pred cap005137 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchB or some CapBenchB) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap005137c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) or (not (inv1 and ((some CapBenchB or some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005137 { cap005137 iff cap005137c }
check CapBenchEquivalent_cap005137 for 4
