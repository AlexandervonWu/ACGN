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

pred cap004833 { not ((inv3 and ((some capBenchS or some CapBenchB) or some capBenchS)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004833c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some capBenchS or some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004833 { cap004833 iff cap004833c }
check CapBenchEquivalent_cap004833 for 4
