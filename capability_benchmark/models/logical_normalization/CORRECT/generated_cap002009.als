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

pred cap002009 { ((inv7 and ((some CapBenchB or some CapBenchB) or some CapBenchA)) iff ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap002009c { (((not (inv7 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (inv7 and ((some CapBenchB or some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap002009 { cap002009 iff cap002009c }
check CapBenchEquivalent_cap002009 for 4
