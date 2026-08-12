sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005308 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005308c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap005308 { cap005308 iff cap005308c }
check CapBenchEquivalent_cap005308 for 4
