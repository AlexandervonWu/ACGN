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

pred cap001565 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) }
pred cap001565c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((some CapBenchB or some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001565 { cap001565 iff cap001565c }
check CapBenchEquivalent_cap001565 for 4
