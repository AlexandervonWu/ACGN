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

pred cap002118 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)))) }
pred cap002118c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
assert CapBenchEquivalent_cap002118 { cap002118 iff cap002118c }
check CapBenchEquivalent_cap002118 for 4
