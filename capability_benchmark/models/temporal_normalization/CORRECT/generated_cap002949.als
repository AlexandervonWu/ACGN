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

pred cap002949 { not (((inv7 and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) since (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB))) }
pred cap002949c { ((not (inv7 and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap002949 { cap002949 iff cap002949c }
check CapBenchEquivalent_cap002949 for 4
