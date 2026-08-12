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

pred cap001657 { ((all x: CapBenchA | x->x in capBenchR) or (inv9 and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
pred cap001657c { (all x: CapBenchA | (x->x in capBenchR or (inv9 and ((some capBenchS or no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001657 { cap001657 iff cap001657c }
check CapBenchEquivalent_cap001657 for 4
