sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004721 { not ((inv3 and ((some capBenchS or no CapBenchB) or no CapBenchB)) and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004721c { ((not ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some capBenchS or no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004721 { cap004721 iff cap004721c }
check CapBenchEquivalent_cap004721 for 4
