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

pred cap004959 { not ((inv3 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap004959c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (not (inv3 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004959 { cap004959 iff cap004959c }
check CapBenchEquivalent_cap004959 for 4
