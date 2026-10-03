sig A, B, C {}
pred candidate { some A and (some B or no C) }
pred oracle { some A and (some B and no C) }
run {} for 3
