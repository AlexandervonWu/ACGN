sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001781 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap001781c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001781 { cap001781 iff cap001781c }
check CapBenchEquivalent_cap001781 for 4
