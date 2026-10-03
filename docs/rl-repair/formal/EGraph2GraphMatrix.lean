import EGraph2Graph

open RepairTransformer

def main : IO Unit := do
  for n in List.range 5 do
    for w in [0, 8, 10, 64] do
      for h in [0, 2, 3, 4] do
        for source in [0, n] do
          for action in [0, n] do
            for mask in [false, true] do
              let r : Request := ⟨n, [⟨source, 0, "USE", 2⟩], [action], [mask], w, h, 2, 8⟩
              IO.println s!"TRANSFORMER,{n},{w},{h},{source},{action},{mask},{admitted r}"
