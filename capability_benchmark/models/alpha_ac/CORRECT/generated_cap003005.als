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

pred cap003005 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some capBenchS or some CapBenchA) or some CapBenchA)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap003005c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((some capBenchS or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003005 { cap003005 iff cap003005c }
check CapBenchEquivalent_cap003005 for 4
