sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
all f,g,h:File | f->g in link implies g->h not in link
}

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000891 { ((inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) or ((no CapBenchA and some capBenchR) and no CapBenchB)) }
pred cap000891c { (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) or ((no CapBenchA and some capBenchR) and no CapBenchB) or (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000891 { cap000891 iff cap000891c }
check CapBenchEquivalent_cap000891 for 4
