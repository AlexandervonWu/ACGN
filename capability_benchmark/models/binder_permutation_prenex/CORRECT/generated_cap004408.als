sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no File.link
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

pred cap004408 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004408c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004408 { cap004408 iff cap004408c }
check CapBenchEquivalent_cap004408 for 4
