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

pred cap005421 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
pred cap005421c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and some CapBenchB)) or (not (inv4 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005421 { cap005421 iff cap005421c }
check CapBenchEquivalent_cap005421 for 4
