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

pred cap000867 { ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS)) or ((some capBenchR and no CapBenchB) or some CapBenchA) or ((no CapBenchA and some CapBenchB) and no CapBenchB)) }
pred cap000867c { (((some capBenchR and no CapBenchB) or some CapBenchA) or ((no CapBenchA and some CapBenchB) and no CapBenchB) or (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap000867 { cap000867 iff cap000867c }
check CapBenchEquivalent_cap000867 for 4
