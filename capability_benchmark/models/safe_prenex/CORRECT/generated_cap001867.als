sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001867 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
pred cap001867c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap001867 { cap001867 iff cap001867c }
check CapBenchEquivalent_cap001867 for 4
