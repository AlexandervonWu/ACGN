sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
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

pred cap002721 { not (((inv3 and ((some capBenchS or no CapBenchB) or no CapBenchB))) since (((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002721c { ((not (inv3 and ((some capBenchS or no CapBenchB) or no CapBenchB))) triggered (not ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002721 { cap002721 iff cap002721c }
check CapBenchEquivalent_cap002721 for 4
