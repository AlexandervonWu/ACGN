sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000764 { ((inv8 and ((some CapBenchA and some CapBenchB) or some capBenchR)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) and ((no CapBenchB or some capBenchR) and some CapBenchB)) }
pred cap000764c { (((no CapBenchB or some capBenchR) and some CapBenchB) and (inv8 and ((some CapBenchA and some CapBenchB) or some capBenchR)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000764 { cap000764 iff cap000764c }
check CapBenchEquivalent_cap000764 for 4
