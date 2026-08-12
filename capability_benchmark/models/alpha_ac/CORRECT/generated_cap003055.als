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

pred cap003055 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((some capBenchR and some capBenchR) or no CapBenchB)) }
pred cap003055c { all renamed: CapBenchA | (((some capBenchR and some capBenchR) or no CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap003055 { cap003055 iff cap003055c }
check CapBenchEquivalent_cap003055 for 4
