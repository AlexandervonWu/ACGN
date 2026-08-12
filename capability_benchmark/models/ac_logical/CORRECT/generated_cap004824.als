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

pred cap004824 { not ((inv7 and ((some capBenchR and some CapBenchA) or some capBenchS)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004824c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv7 and ((some capBenchR and some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap004824 { cap004824 iff cap004824c }
check CapBenchEquivalent_cap004824 for 4
