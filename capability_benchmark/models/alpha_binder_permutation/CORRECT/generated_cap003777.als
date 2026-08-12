sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
all f1, f2, f3 : File | (f1 -> f2 in link && f1 -> f3 in link) => f2 = f3
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

pred cap003777 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some capBenchS or no CapBenchA) or some capBenchR))) }
pred cap003777c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((some capBenchS or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003777 { cap003777 iff cap003777c }
check CapBenchEquivalent_cap003777 for 4
