sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no (link.Trash)
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

pred cap001877 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap001877c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001877 { cap001877 iff cap001877c }
check CapBenchEquivalent_cap001877 for 4
