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

pred cap005183 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((some capBenchR and some capBenchR) or some capBenchS))) }
pred cap005183c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some capBenchR) or some capBenchS)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005183 { cap005183 iff cap005183c }
check CapBenchEquivalent_cap005183 for 4
