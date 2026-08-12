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

pred cap002547 { not (((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) since (((some capBenchR and no CapBenchB) or no CapBenchB))) }
pred cap002547c { ((not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) triggered (not ((some capBenchR and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002547 { cap002547 iff cap002547c }
check CapBenchEquivalent_cap002547 for 4
