sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001008 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
pred cap001008c { all a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap001008 { cap001008 iff cap001008c }
check CapBenchEquivalent_cap001008 for 4
