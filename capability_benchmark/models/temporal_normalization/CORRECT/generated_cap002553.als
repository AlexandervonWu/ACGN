sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
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

pred cap002553 { not (((inv8 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) since (((no CapBenchA and some capBenchR) and no CapBenchB))) }
pred cap002553c { ((not (inv8 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) triggered (not ((no CapBenchA and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap002553 { cap002553 iff cap002553c }
check CapBenchEquivalent_cap002553 for 4
