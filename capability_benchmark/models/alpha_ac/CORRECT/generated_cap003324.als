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

pred cap003324 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and some CapBenchA) or some capBenchS)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003324c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some capBenchR and some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003324 { cap003324 iff cap003324c }
check CapBenchEquivalent_cap003324 for 4
