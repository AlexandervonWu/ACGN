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

pred cap004990 { not ((inv8 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) }
pred cap004990c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) or (not (inv8 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004990 { cap004990 iff cap004990c }
check CapBenchEquivalent_cap004990 for 4
