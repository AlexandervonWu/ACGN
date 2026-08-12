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

pred cap002385 { not ((inv1 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) }
pred cap002385c { ((not (inv1 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap002385 { cap002385 iff cap002385c }
check CapBenchEquivalent_cap002385 for 4
