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

pred cap002281 { no x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap002281c { all x: CapBenchA | not (x->x in capBenchR and (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002281 { cap002281 iff cap002281c }
check CapBenchEquivalent_cap002281 for 4
