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

pred cap003125 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((no CapBenchA and some capBenchS) and some capBenchR)) }
pred cap003125c { all renamed: CapBenchA | (((no CapBenchA and some capBenchS) and some capBenchR) and renamed->renamed in capBenchR and (inv5 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003125 { cap003125 iff cap003125c }
check CapBenchEquivalent_cap003125 for 4
