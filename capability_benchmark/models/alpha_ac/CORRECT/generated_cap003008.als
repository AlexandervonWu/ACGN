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

pred cap003008 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchA and some CapBenchB) or some CapBenchA)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap003008c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchA and some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003008 { cap003008 iff cap003008c }
check CapBenchEquivalent_cap003008 for 4
