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

pred cap002367 { not ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)) and ((some capBenchR and no CapBenchB) or some CapBenchA)) }
pred cap002367c { ((not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) or (not ((some capBenchR and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002367 { cap002367 iff cap002367c }
check CapBenchEquivalent_cap002367 for 4
