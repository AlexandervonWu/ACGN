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

pred cap002214 { not (all x: CapBenchA | (x->x in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)))) }
pred cap002214c { some x: CapBenchA | not (x->x in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002214 { cap002214 iff cap002214c }
check CapBenchEquivalent_cap002214 for 4
