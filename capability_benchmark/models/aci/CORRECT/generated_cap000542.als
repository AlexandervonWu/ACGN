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

pred cap000542 { ((inv3 and ((no CapBenchA and some capBenchS) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB) and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000542c { (((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and (inv3 and ((no CapBenchA and some capBenchS) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)) }
assert CapBenchEquivalent_cap000542 { cap000542 iff cap000542c }
check CapBenchEquivalent_cap000542 for 4
