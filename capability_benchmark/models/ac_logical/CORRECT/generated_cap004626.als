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

pred cap004626 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((no CapBenchB or some capBenchS) and some capBenchR)) }
pred cap004626c { ((not ((no CapBenchB or some capBenchS) and some capBenchR)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004626 { cap004626 iff cap004626c }
check CapBenchEquivalent_cap004626 for 4
