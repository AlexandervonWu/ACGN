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

pred cap002387 { ((inv1 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) iff ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap002387c { (((not (inv1 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or (inv1 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002387 { cap002387 iff cap002387c }
check CapBenchEquivalent_cap002387 for 4
