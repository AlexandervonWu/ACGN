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

pred cap002636 { not (((inv1 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) until (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap002636c { ((not (inv1 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) releases (not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap002636 { cap002636 iff cap002636c }
check CapBenchEquivalent_cap002636 for 4
