sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003731 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap003731c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap003731 { cap003731 iff cap003731c }
check CapBenchEquivalent_cap003731 for 4
