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

pred cap003581 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
pred cap003581c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003581 { cap003581 iff cap003581c }
check CapBenchEquivalent_cap003581 for 4
