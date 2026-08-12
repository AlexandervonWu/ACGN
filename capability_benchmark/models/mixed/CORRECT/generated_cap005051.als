sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005051 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
pred cap005051c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchR) or no CapBenchB)) or (not (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005051 { cap005051 iff cap005051c }
check CapBenchEquivalent_cap005051 for 4
