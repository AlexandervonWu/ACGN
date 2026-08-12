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

pred cap005229 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some capBenchS or some capBenchR) or no CapBenchB)) and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005229c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv7 and ((some capBenchS or some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005229 { cap005229 iff cap005229c }
check CapBenchEquivalent_cap005229 for 4
