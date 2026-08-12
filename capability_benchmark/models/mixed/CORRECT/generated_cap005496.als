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

pred cap005496 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
pred cap005496c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or no CapBenchA)) or (not (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005496 { cap005496 iff cap005496c }
check CapBenchEquivalent_cap005496 for 4
