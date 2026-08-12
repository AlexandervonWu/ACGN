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

pred cap003002 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) }
pred cap003002c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003002 { cap003002 iff cap003002c }
check CapBenchEquivalent_cap003002 for 4
