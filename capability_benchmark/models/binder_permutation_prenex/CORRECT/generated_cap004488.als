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

pred cap004488 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004488c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004488 { cap004488 iff cap004488c }
check CapBenchEquivalent_cap004488 for 4
