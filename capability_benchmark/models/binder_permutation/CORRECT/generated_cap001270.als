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

pred cap001270 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
pred cap001270c { all a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap001270 { cap001270 iff cap001270c }
check CapBenchEquivalent_cap001270 for 4
