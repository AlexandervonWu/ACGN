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

pred cap000962 { ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB) and ((some CapBenchB or some capBenchS) or some capBenchR)) }
pred cap000962c { (((some CapBenchB or some capBenchS) or some capBenchR) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) }
assert CapBenchEquivalent_cap000962 { cap000962 iff cap000962c }
check CapBenchEquivalent_cap000962 for 4
