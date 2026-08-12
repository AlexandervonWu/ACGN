sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004677 { not ((inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) }
pred cap004677c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) or (not (inv8 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004677 { cap004677 iff cap004677c }
check CapBenchEquivalent_cap004677 for 4
