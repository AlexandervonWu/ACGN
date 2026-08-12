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

pred cap000514 { (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) }
pred cap000514c { ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000514 { cap000514 iff cap000514c }
check CapBenchEquivalent_cap000514 for 4
