sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap002973 { not (((inv3 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) since (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) }
pred cap002973c { ((not (inv3 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002973 { cap002973 iff cap002973c }
check CapBenchEquivalent_cap002973 for 4
