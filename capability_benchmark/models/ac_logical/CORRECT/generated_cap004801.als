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

pred cap004801 { not ((inv3 and ((some capBenchS or some capBenchS) or some capBenchR)) and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004801c { ((not ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some capBenchS or some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap004801 { cap004801 iff cap004801c }
check CapBenchEquivalent_cap004801 for 4
