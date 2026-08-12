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

pred cap000895 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv5 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000895c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv5 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000895 { cap000895 iff cap000895c }
check CapBenchEquivalent_cap000895 for 4
