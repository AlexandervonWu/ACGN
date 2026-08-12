sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no (link.Trash)
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

pred cap002822 { not (((inv7 and ((no CapBenchA and some CapBenchA) and some capBenchS))) until (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002822c { ((not (inv7 and ((no CapBenchA and some CapBenchA) and some capBenchS))) releases (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002822 { cap002822 iff cap002822c }
check CapBenchEquivalent_cap002822 for 4
