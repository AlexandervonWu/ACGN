sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
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

pred cap000425 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000425c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000425 { cap000425 iff cap000425c }
check CapBenchEquivalent_cap000425 for 4
