sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File| f not in Protected => f in Trash
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

pred cap000345 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
pred cap000345c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000345 { cap000345 iff cap000345c }
check CapBenchEquivalent_cap000345 for 4
