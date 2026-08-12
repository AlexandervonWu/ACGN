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

pred cap000945 { ((inv9 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or ((no CapBenchA and some capBenchS) and some CapBenchB) or ((some CapBenchA and no CapBenchB) or some capBenchR)) }
pred cap000945c { (((no CapBenchA and some capBenchS) and some CapBenchB) or ((some CapBenchA and no CapBenchB) or some capBenchR) or (inv9 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000945 { cap000945 iff cap000945c }
check CapBenchEquivalent_cap000945 for 4
