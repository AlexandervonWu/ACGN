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

pred cap000522 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
pred cap000522c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000522 { cap000522 iff cap000522c }
check CapBenchEquivalent_cap000522 for 4
