sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002775 { not (((inv3 and ((no CapBenchB or no CapBenchA) and some capBenchR))) since (((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002775c { ((not (inv3 and ((no CapBenchB or no CapBenchA) and some capBenchR))) triggered (not ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002775 { cap002775 iff cap002775c }
check CapBenchEquivalent_cap002775 for 4
