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

pred cap002613 { not (((inv6 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) since (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
pred cap002613c { ((not (inv6 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002613 { cap002613 iff cap002613c }
check CapBenchEquivalent_cap002613 for 4
