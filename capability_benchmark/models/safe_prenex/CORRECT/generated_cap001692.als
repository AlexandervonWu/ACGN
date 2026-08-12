sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001692 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
pred cap001692c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchA and some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001692 { cap001692 iff cap001692c }
check CapBenchEquivalent_cap001692 for 4
