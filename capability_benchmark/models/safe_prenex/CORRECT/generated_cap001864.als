sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
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

pred cap001864 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some capBenchR and some capBenchS) or some capBenchS))) }
pred cap001864c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap001864 { cap001864 iff cap001864c }
check CapBenchEquivalent_cap001864 for 4
