sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
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

pred cap003806 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap003806c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap003806 { cap003806 iff cap003806c }
check CapBenchEquivalent_cap003806 for 4
