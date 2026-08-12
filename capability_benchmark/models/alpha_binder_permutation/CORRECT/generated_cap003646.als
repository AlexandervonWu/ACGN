sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
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

pred cap003646 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
pred cap003646c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003646 { cap003646 iff cap003646c }
check CapBenchEquivalent_cap003646 for 4
