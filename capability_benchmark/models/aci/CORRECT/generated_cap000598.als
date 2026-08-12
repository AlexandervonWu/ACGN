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

pred cap000598 { (inv8 and ((no CapBenchA and some capBenchR) and some CapBenchB)) }
pred cap000598c { ((inv8 and ((no CapBenchA and some capBenchR) and some CapBenchB)) and (inv8 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap000598 { cap000598 iff cap000598c }
check CapBenchEquivalent_cap000598 for 4
