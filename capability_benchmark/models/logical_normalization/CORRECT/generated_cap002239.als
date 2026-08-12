sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002239 { no x: CapBenchA | (x->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap002239c { all x: CapBenchA | not (x->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap002239 { cap002239 iff cap002239c }
check CapBenchEquivalent_cap002239 for 4
