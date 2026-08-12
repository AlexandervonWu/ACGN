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

pred cap003280 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchA and no CapBenchB) or some capBenchR)) and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003280c { all renamed: CapBenchA | (((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv9 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003280 { cap003280 iff cap003280c }
check CapBenchEquivalent_cap003280 for 4
