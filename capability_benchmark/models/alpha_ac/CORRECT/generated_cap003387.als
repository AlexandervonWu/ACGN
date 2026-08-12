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

pred cap003387 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap003387c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003387 { cap003387 iff cap003387c }
check CapBenchEquivalent_cap003387 for 4
