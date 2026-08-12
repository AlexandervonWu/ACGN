sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000770 { ((inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and ((some CapBenchB or some capBenchS) or some CapBenchB)) }
pred cap000770c { (((some CapBenchB or some capBenchS) or some CapBenchB) and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000770 { cap000770 iff cap000770c }
check CapBenchEquivalent_cap000770 for 4
