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

pred cap003457 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap003457c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003457 { cap003457 iff cap003457c }
check CapBenchEquivalent_cap003457 for 4
