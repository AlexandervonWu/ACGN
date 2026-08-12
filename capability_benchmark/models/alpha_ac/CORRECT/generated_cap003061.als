sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
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

pred cap003061 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((no CapBenchA and some capBenchS) and no CapBenchB)) }
pred cap003061c { all renamed: CapBenchA | (((no CapBenchA and some capBenchS) and no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003061 { cap003061 iff cap003061c }
check CapBenchEquivalent_cap003061 for 4
