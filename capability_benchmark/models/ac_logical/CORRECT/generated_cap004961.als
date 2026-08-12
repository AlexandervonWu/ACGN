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

pred cap004961 { not ((inv6 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) }
pred cap004961c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) or (not (inv6 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004961 { cap004961 iff cap004961c }
check CapBenchEquivalent_cap004961 for 4
