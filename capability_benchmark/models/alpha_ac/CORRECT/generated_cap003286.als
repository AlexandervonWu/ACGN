sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no File.link
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

pred cap003286 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)) and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003286c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003286 { cap003286 iff cap003286c }
check CapBenchEquivalent_cap003286 for 4
