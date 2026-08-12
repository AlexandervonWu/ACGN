sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005343 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) and ((some capBenchR and some CapBenchA) or some CapBenchA))) }
pred cap005343c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchA) or some CapBenchA)) or (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap005343 { cap005343 iff cap005343c }
check CapBenchEquivalent_cap005343 for 4
