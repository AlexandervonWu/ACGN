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

pred cap002778 { not historically ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR))) }
pred cap002778c { once (not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002778 { cap002778 iff cap002778c }
check CapBenchEquivalent_cap002778 for 4
