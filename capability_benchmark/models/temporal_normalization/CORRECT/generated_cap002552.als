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

pred cap002552 { not (((inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) until (((some CapBenchB or some capBenchR) or no CapBenchB))) }
pred cap002552c { ((not (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) releases (not ((some CapBenchB or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap002552 { cap002552 iff cap002552c }
check CapBenchEquivalent_cap002552 for 4
