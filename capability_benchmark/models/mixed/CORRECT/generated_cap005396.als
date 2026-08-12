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

pred cap005396 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap005396c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or (not (inv5 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005396 { cap005396 iff cap005396c }
check CapBenchEquivalent_cap005396 for 4
