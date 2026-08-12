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

pred cap003799 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
pred cap003799c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap003799 { cap003799 iff cap003799c }
check CapBenchEquivalent_cap003799 for 4
