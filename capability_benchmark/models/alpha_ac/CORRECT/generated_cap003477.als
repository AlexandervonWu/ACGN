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

pred cap003477 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and some CapBenchB) and no CapBenchA)) }
pred cap003477c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003477 { cap003477 iff cap003477c }
check CapBenchEquivalent_cap003477 for 4
