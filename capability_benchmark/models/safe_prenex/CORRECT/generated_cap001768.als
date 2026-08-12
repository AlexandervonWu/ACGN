sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all p : Protected | p  not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001768 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some capBenchR and some CapBenchB) or some capBenchR))) }
pred cap001768c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001768 { cap001768 iff cap001768c }
check CapBenchEquivalent_cap001768 for 4
