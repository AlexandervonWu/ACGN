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

pred cap002430 { not (all x: CapBenchA | (x->x in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
pred cap002430c { some x: CapBenchA | not (x->x in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002430 { cap002430 iff cap002430c }
check CapBenchEquivalent_cap002430 for 4
