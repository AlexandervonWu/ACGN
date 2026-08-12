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

pred cap002913 { not (((inv8 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) since (((no CapBenchA and some CapBenchB) and some CapBenchB))) }
pred cap002913c { ((not (inv8 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) triggered (not ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002913 { cap002913 iff cap002913c }
check CapBenchEquivalent_cap002913 for 4
