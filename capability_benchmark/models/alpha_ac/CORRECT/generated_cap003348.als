sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
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

pred cap003348 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or some capBenchS)) and ((some CapBenchB or some CapBenchB) or some CapBenchA)) }
pred cap003348c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003348 { cap003348 iff cap003348c }
check CapBenchEquivalent_cap003348 for 4
