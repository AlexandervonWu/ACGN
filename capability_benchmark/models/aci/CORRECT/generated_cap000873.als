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

pred cap000873 { ((inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or ((no CapBenchA and some capBenchR) and some CapBenchA) or ((some CapBenchA and no CapBenchA) or no CapBenchB)) }
pred cap000873c { (((no CapBenchA and some capBenchR) and some CapBenchA) or ((some CapBenchA and no CapBenchA) or no CapBenchB) or (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap000873 { cap000873 iff cap000873c }
check CapBenchEquivalent_cap000873 for 4
