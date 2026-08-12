sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005323 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchB or some CapBenchA) and some capBenchS)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005323c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv8 and ((no CapBenchB or some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap005323 { cap005323 iff cap005323c }
check CapBenchEquivalent_cap005323 for 4
