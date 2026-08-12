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

pred cap002756 { not (((inv1 and ((some CapBenchA and some CapBenchA) or some capBenchR))) until (((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002756c { ((not (inv1 and ((some CapBenchA and some CapBenchA) or some capBenchR))) releases (not ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002756 { cap002756 iff cap002756c }
check CapBenchEquivalent_cap002756 for 4
