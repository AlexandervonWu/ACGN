sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001918 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001918c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001918 { cap001918 iff cap001918c }
check CapBenchEquivalent_cap001918 for 4
