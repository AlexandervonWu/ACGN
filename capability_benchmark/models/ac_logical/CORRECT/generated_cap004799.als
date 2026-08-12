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

pred cap004799 { not ((inv3 and ((no CapBenchB or some capBenchS) and some capBenchR)) and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004799c { ((not ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((no CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap004799 { cap004799 iff cap004799c }
check CapBenchEquivalent_cap004799 for 4
