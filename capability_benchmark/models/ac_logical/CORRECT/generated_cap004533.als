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

pred cap004533 { not ((inv7 and ((some CapBenchB or some capBenchR) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) }
pred cap004533c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) or (not (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004533 { cap004533 iff cap004533c }
check CapBenchEquivalent_cap004533 for 4
