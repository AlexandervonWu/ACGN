sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
no File.link.link
}

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000620 { ((inv9 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some capBenchS or some capBenchR) or some capBenchR) and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000620c { (((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and (inv9 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some capBenchS or some capBenchR) or some capBenchR)) }
assert CapBenchEquivalent_cap000620 { cap000620 iff cap000620c }
check CapBenchEquivalent_cap000620 for 4
