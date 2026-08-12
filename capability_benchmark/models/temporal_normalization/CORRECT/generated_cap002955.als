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

pred cap002955 { not (((inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) since (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap002955c { ((not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) triggered (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap002955 { cap002955 iff cap002955c }
check CapBenchEquivalent_cap002955 for 4
