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

pred cap005479 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and some CapBenchB) or no CapBenchA))) }
pred cap005479c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchB) or no CapBenchA)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005479 { cap005479 iff cap005479c }
check CapBenchEquivalent_cap005479 for 4
