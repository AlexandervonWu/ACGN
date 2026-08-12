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

pred cap000124 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap000124c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000124 { cap000124 iff cap000124c }
check CapBenchEquivalent_cap000124 for 4
