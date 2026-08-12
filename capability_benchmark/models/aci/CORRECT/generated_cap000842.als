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

pred cap000842 { ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) and ((no CapBenchB or some CapBenchA) and some CapBenchA) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap000842c { (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) and ((no CapBenchB or some CapBenchA) and some CapBenchA)) }
assert CapBenchEquivalent_cap000842 { cap000842 iff cap000842c }
check CapBenchEquivalent_cap000842 for 4
