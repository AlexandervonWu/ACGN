sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001985 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001985c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001985 { cap001985 iff cap001985c }
check CapBenchEquivalent_cap001985 for 4
