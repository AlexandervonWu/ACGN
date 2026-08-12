sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000505 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv7 and ((some capBenchS or some CapBenchA) or some CapBenchA))) }
pred cap000505c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv7 and ((some capBenchS or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000505 { cap000505 iff cap000505c }
check CapBenchEquivalent_cap000505 for 4
