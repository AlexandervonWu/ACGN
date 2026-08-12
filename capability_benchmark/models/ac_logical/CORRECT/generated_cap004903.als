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

pred cap004903 { not ((inv7 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some CapBenchA) or some CapBenchB)) }
pred cap004903c { ((not ((some CapBenchA and some CapBenchA) or some CapBenchB)) or (not (inv7 and ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004903 { cap004903 iff cap004903c }
check CapBenchEquivalent_cap004903 for 4
