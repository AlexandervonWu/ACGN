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

pred cap002400 { not (all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
pred cap002400c { some x: CapBenchA | not (x->x in capBenchR and (inv9 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002400 { cap002400 iff cap002400c }
check CapBenchEquivalent_cap002400 for 4
