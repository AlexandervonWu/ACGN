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

pred cap002111 { ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) iff ((some capBenchR and no CapBenchB) or some capBenchR)) }
pred cap002111c { (((not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB))) or ((some capBenchR and no CapBenchB) or some capBenchR)) and ((not ((some capBenchR and no CapBenchB) or some capBenchR)) or (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap002111 { cap002111 iff cap002111c }
check CapBenchEquivalent_cap002111 for 4
