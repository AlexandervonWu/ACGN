sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003006 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap003006c { all renamed: CapBenchA | (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003006 { cap003006 iff cap003006c }
check CapBenchEquivalent_cap003006 for 4
