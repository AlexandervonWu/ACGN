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

pred cap000421 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000421c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000421 { cap000421 iff cap000421c }
check CapBenchEquivalent_cap000421 for 4
