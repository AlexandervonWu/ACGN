sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005368 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
pred cap005368c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or some CapBenchA)) or (not (inv8 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap005368 { cap005368 iff cap005368c }
check CapBenchEquivalent_cap005368 for 4
