sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004609 { not ((inv7 and ((some capBenchS or some capBenchS) or some CapBenchB)) and ((no CapBenchA and no CapBenchB) and some capBenchR)) }
pred cap004609c { ((not ((no CapBenchA and no CapBenchB) and some capBenchR)) or (not (inv7 and ((some capBenchS or some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004609 { cap004609 iff cap004609c }
check CapBenchEquivalent_cap004609 for 4
