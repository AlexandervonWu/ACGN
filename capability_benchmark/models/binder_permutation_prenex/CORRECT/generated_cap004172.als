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

pred cap004172 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
pred cap004172c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap004172 { cap004172 iff cap004172c }
check CapBenchEquivalent_cap004172 for 4
