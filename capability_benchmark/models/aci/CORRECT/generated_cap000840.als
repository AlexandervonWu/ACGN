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

pred cap000840 { (some ((CapBenchA.capBenchR).capBenchR) and (inv4 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
pred cap000840c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv4 and ((some capBenchR and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap000840 { cap000840 iff cap000840c }
check CapBenchEquivalent_cap000840 for 4
