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

pred cap002666 { not (((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) until (((no CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap002666c { ((not (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) releases (not ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002666 { cap002666 iff cap002666c }
check CapBenchEquivalent_cap002666 for 4
