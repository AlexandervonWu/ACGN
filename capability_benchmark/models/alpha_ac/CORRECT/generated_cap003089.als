sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003089 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or no CapBenchB) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)) }
pred cap003089c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003089 { cap003089 iff cap003089c }
check CapBenchEquivalent_cap003089 for 4
