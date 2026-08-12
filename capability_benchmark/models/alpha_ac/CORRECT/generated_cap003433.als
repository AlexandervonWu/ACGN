sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003433 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) }
pred cap003433c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003433 { cap003433 iff cap003433c }
check CapBenchEquivalent_cap003433 for 4
