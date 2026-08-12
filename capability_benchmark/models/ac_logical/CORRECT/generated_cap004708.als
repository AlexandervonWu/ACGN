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

pred cap004708 { not ((inv9 and ((some CapBenchA and no CapBenchA) or no CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap004708c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv9 and ((some CapBenchA and no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004708 { cap004708 iff cap004708c }
check CapBenchEquivalent_cap004708 for 4
