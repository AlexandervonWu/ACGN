sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
all f,lk1 : File | f->lk1 in link implies lk1 not in Trash
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

pred cap002472 { not (all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
pred cap002472c { some x: CapBenchA | not (x->x in capBenchR and (inv7 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002472 { cap002472 iff cap002472c }
check CapBenchEquivalent_cap002472 for 4
