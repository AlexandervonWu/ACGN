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

pred cap002091 { not ((inv6 and ((no CapBenchB or no CapBenchB) and some CapBenchB)) and ((some CapBenchA and some CapBenchB) or some capBenchR)) }
pred cap002091c { ((not (inv6 and ((no CapBenchB or no CapBenchB) and some CapBenchB))) or (not ((some CapBenchA and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002091 { cap002091 iff cap002091c }
check CapBenchEquivalent_cap002091 for 4
