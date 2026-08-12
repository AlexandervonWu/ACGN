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

pred cap000509 { (inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchA)) }
pred cap000509c { ((inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchA)) or (inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000509 { cap000509 iff cap000509c }
check CapBenchEquivalent_cap000509 for 4
