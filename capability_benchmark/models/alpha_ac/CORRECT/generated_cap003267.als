sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File| f not in Protected => f in Trash
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

pred cap003267 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and some capBenchR)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003267c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003267 { cap003267 iff cap003267c }
check CapBenchEquivalent_cap003267 for 4
