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

pred cap003381 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((no CapBenchA and some capBenchS) and some CapBenchA)) }
pred cap003381c { all renamed: CapBenchA | (((no CapBenchA and some capBenchS) and some CapBenchA) and renamed->renamed in capBenchR and (inv7 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003381 { cap003381 iff cap003381c }
check CapBenchEquivalent_cap003381 for 4
