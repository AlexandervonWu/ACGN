sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no (link.Trash)
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

pred cap000765 { ((inv7 and ((some CapBenchB or some CapBenchB) or some capBenchR)) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)) or ((some capBenchR and some capBenchR) or some CapBenchB)) }
pred cap000765c { (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)) or ((some capBenchR and some capBenchR) or some CapBenchB) or (inv7 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000765 { cap000765 iff cap000765c }
check CapBenchEquivalent_cap000765 for 4
