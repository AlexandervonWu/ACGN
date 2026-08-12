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

pred cap001905 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001905c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001905 { cap001905 iff cap001905c }
check CapBenchEquivalent_cap001905 for 4
