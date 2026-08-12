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

pred cap001942 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001942c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001942 { cap001942 iff cap001942c }
check CapBenchEquivalent_cap001942 for 4
