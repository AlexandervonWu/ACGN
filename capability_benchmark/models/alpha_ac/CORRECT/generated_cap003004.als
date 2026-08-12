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

pred cap003004 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some capBenchR and some CapBenchA) or some CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap003004c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((some capBenchR and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003004 { cap003004 iff cap003004c }
check CapBenchEquivalent_cap003004 for 4
