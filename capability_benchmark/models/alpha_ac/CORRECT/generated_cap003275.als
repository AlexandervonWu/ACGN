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

pred cap003275 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchR)) and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003275c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003275 { cap003275 iff cap003275c }
check CapBenchEquivalent_cap003275 for 4
