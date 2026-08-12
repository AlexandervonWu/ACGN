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

pred cap000512 { ((inv9 and ((some capBenchR and some CapBenchB) or some CapBenchA)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) }
pred cap000512c { (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS) and (inv9 and ((some capBenchR and some CapBenchB) or some CapBenchA)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
assert CapBenchEquivalent_cap000512 { cap000512 iff cap000512c }
check CapBenchEquivalent_cap000512 for 4
