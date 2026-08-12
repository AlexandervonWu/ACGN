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

pred cap004616 { not ((inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((some CapBenchB or some capBenchR) or some capBenchR)) }
pred cap004616c { ((not ((some CapBenchB or some capBenchR) or some capBenchR)) or (not (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004616 { cap004616 iff cap004616c }
check CapBenchEquivalent_cap004616 for 4
