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

pred cap003351 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) and ((some capBenchR and some CapBenchB) or some CapBenchA)) }
pred cap003351c { all renamed: CapBenchA | (((some capBenchR and some CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003351 { cap003351 iff cap003351c }
check CapBenchEquivalent_cap003351 for 4
