sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
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

pred cap001711 { ((all x: CapBenchA | x->x in capBenchR) or (inv8 and ((no CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap001711c { (all x: CapBenchA | (x->x in capBenchR or (inv8 and ((no CapBenchB or no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001711 { cap001711 iff cap001711c }
check CapBenchEquivalent_cap001711 for 4
