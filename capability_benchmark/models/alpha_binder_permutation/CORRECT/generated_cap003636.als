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

pred cap003636 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
pred cap003636c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003636 { cap003636 iff cap003636c }
check CapBenchEquivalent_cap003636 for 4
