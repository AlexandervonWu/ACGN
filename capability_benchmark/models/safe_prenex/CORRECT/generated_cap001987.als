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

pred cap001987 { ((all x: CapBenchA | x->x in capBenchR) or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001987c { (all x: CapBenchA | (x->x in capBenchR or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001987 { cap001987 iff cap001987c }
check CapBenchEquivalent_cap001987 for 4
