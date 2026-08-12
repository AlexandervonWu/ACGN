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

pred cap002195 { ((inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB)) iff ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap002195c { (((not (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap002195 { cap002195 iff cap002195c }
check CapBenchEquivalent_cap002195 for 4
