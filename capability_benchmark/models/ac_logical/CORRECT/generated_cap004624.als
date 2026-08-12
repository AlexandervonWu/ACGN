sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004624 { not ((inv7 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((some CapBenchB or some capBenchS) or some capBenchR)) }
pred cap004624c { ((not ((some CapBenchB or some capBenchS) or some capBenchR)) or (not (inv7 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004624 { cap004624 iff cap004624c }
check CapBenchEquivalent_cap004624 for 4
