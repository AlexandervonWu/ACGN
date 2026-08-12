sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File| f not in Protected => f in Trash
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

pred cap001980 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001980c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001980 { cap001980 iff cap001980c }
check CapBenchEquivalent_cap001980 for 4
