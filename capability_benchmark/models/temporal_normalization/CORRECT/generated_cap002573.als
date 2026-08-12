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

pred cap002573 { not eventually ((inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchB))) }
pred cap002573c { always (not (inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002573 { cap002573 iff cap002573c }
check CapBenchEquivalent_cap002573 for 4
