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

pred cap003230 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003230c { all renamed: CapBenchA | (((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap003230 { cap003230 iff cap003230c }
check CapBenchEquivalent_cap003230 for 4
