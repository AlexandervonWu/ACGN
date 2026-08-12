sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
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

pred cap001873 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap001873c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap001873 { cap001873 iff cap001873c }
check CapBenchEquivalent_cap001873 for 4
