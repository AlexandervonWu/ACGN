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

pred cap004676 { not ((inv1 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some capBenchS or no CapBenchB) or some capBenchS)) }
pred cap004676c { ((not ((some capBenchS or no CapBenchB) or some capBenchS)) or (not (inv1 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004676 { cap004676 iff cap004676c }
check CapBenchEquivalent_cap004676 for 4
