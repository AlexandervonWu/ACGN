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

pred cap002543 { not eventually ((inv7 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap002543c { always (not (inv7 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap002543 { cap002543 iff cap002543c }
check CapBenchEquivalent_cap002543 for 4
