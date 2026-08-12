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

pred cap002343 { not ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) and ((some capBenchR and some CapBenchA) or some CapBenchA)) }
pred cap002343c { ((not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) or (not ((some capBenchR and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002343 { cap002343 iff cap002343c }
check CapBenchEquivalent_cap002343 for 4
