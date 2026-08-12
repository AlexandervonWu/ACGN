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

pred cap003354 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) }
pred cap003354c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap003354 { cap003354 iff cap003354c }
check CapBenchEquivalent_cap003354 for 4
