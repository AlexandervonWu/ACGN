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

pred cap000588 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv7 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) }
pred cap000588c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv7 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000588 { cap000588 iff cap000588c }
check CapBenchEquivalent_cap000588 for 4
