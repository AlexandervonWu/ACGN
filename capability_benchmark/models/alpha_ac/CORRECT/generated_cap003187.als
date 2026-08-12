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

pred cap003187 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((some CapBenchA and some capBenchS) or some capBenchS)) }
pred cap003187c { all renamed: CapBenchA | (((some CapBenchA and some capBenchS) or some capBenchS) and renamed->renamed in capBenchR and (inv7 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003187 { cap003187 iff cap003187c }
check CapBenchEquivalent_cap003187 for 4
