sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
all f,lk1 : File | f->lk1 in link implies lk1 not in Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003558 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap003558c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003558 { cap003558 iff cap003558c }
check CapBenchEquivalent_cap003558 for 4
