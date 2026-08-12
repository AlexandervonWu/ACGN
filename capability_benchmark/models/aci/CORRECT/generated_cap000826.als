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

pred cap000826 { (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) }
pred cap000826c { ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000826 { cap000826 iff cap000826c }
check CapBenchEquivalent_cap000826 for 4
