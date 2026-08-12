sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
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

pred cap004668 { not ((inv8 and ((some CapBenchA and some capBenchS) or no CapBenchA)) and ((some capBenchS or no CapBenchA) or some capBenchS)) }
pred cap004668c { ((not ((some capBenchS or no CapBenchA) or some capBenchS)) or (not (inv8 and ((some CapBenchA and some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004668 { cap004668 iff cap004668c }
check CapBenchEquivalent_cap004668 for 4
