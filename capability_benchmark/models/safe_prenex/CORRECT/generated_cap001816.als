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

pred cap001816 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap001816c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001816 { cap001816 iff cap001816c }
check CapBenchEquivalent_cap001816 for 4
