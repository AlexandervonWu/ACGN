sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
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

pred cap004730 { not ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004730c { ((not ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004730 { cap004730 iff cap004730c }
check CapBenchEquivalent_cap004730 for 4
