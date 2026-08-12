sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
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

pred cap004359 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
pred cap004359c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap004359 { cap004359 iff cap004359c }
check CapBenchEquivalent_cap004359 for 4
