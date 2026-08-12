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

pred cap003440 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some capBenchR) or some CapBenchB)) }
pred cap003440c { all renamed: CapBenchA | (((some capBenchS or some capBenchR) or some CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003440 { cap003440 iff cap003440c }
check CapBenchEquivalent_cap003440 for 4
