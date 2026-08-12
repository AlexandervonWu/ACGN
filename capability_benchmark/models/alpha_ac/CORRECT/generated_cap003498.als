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

pred cap003498 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) }
pred cap003498c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003498 { cap003498 iff cap003498c }
check CapBenchEquivalent_cap003498 for 4
