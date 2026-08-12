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

pred cap002223 { not ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002223c { ((not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) or (not ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002223 { cap002223 iff cap002223c }
check CapBenchEquivalent_cap002223 for 4
