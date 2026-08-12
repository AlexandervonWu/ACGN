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

pred cap001537 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
pred cap001537c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some capBenchS or some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001537 { cap001537 iff cap001537c }
check CapBenchEquivalent_cap001537 for 4
