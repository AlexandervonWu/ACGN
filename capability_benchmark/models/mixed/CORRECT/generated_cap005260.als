sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
no File.link.link
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

pred cap005260 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some capBenchR and some CapBenchA) or some capBenchR)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005260c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv9 and ((some capBenchR and some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap005260 { cap005260 iff cap005260c }
check CapBenchEquivalent_cap005260 for 4
