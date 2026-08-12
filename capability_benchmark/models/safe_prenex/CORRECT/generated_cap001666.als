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

pred cap001666 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
pred cap001666c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001666 { cap001666 iff cap001666c }
check CapBenchEquivalent_cap001666 for 4
