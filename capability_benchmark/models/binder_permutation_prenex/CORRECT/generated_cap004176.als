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

pred cap004176 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap004176c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap004176 { cap004176 iff cap004176c }
check CapBenchEquivalent_cap004176 for 4
