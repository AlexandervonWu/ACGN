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

pred cap001272 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or some capBenchR))) }
pred cap001272c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap001272 { cap001272 iff cap001272c }
check CapBenchEquivalent_cap001272 for 4
