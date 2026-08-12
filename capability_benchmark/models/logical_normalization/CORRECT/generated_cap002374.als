sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002374 { ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) implies ((no CapBenchB or some capBenchR) and some CapBenchA)) }
pred cap002374c { ((not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) or ((no CapBenchB or some capBenchR) and some CapBenchA)) }
assert CapBenchEquivalent_cap002374 { cap002374 iff cap002374c }
check CapBenchEquivalent_cap002374 for 4
