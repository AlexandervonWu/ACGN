sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
no File.link.link
}

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001378 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap001378c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap001378 { cap001378 iff cap001378c }
check CapBenchEquivalent_cap001378 for 4
