sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004620 { not ((inv5 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some capBenchS or some capBenchR) or some capBenchR)) }
pred cap004620c { ((not ((some capBenchS or some capBenchR) or some capBenchR)) or (not (inv5 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004620 { cap004620 iff cap004620c }
check CapBenchEquivalent_cap004620 for 4
