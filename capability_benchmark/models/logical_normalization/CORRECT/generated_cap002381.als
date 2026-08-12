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

pred cap002381 { ((inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) iff ((no CapBenchA and some capBenchS) and some CapBenchA)) }
pred cap002381c { (((not (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) or ((no CapBenchA and some capBenchS) and some CapBenchA)) and ((not ((no CapBenchA and some capBenchS) and some CapBenchA)) or (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap002381 { cap002381 iff cap002381c }
check CapBenchEquivalent_cap002381 for 4
