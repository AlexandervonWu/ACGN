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

pred cap005455 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap005455c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) or (not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005455 { cap005455 iff cap005455c }
check CapBenchEquivalent_cap005455 for 4
