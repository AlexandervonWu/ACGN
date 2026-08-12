sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File | f not in Protected implies f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000387 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000387c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000387 { cap000387 iff cap000387c }
check CapBenchEquivalent_cap000387 for 4
