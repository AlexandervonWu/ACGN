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

pred cap002499 { not ((inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some capBenchR) or no CapBenchA)) }
pred cap002499c { ((not (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) or (not ((some CapBenchA and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap002499 { cap002499 iff cap002499c }
check CapBenchEquivalent_cap002499 for 4
