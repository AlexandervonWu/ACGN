sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
all f:File | f not in Trash
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

pred cap000781 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap000781c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000781 { cap000781 iff cap000781c }
check CapBenchEquivalent_cap000781 for 4
