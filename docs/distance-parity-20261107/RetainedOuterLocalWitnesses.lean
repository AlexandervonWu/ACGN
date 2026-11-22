import RetainedOuterLocalSeparation

/- Generated scope-name instances from the checked original-owner census.
   Alias construction is the existing LocalOwnerCorrespondence check, not
   proof of Java object identity or a production admission claim. -/
namespace RetainedOuterLocalWitnesses
open RetainedBothLocalPaid RetainedOuterLocalSeparation

def d0e0Outer : List String := ["_q0", "_q1"]
theorem d0e0Owner0 : Scope d0e0Outer ["@fast-local:0:1", "@fast-local:0:0", "_q0", "_q1"] ["@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter ((Scope.enter (Scope.root) "@fast-local:0:0" (by decide))) "@fast-local:0:1" (by decide))
theorem d0e0Owner1 : Scope d0e0Outer ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0", "_q0", "_q1"] ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter (d0e0Owner0) "@fast-local:1:0" (by decide))

def d0e1Outer : List String := ["_q3"]
theorem d0e1Owner0 : Scope d0e1Outer ["@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter ((Scope.enter (Scope.root) "@fast-local:0:0" (by decide))) "@fast-local:0:1" (by decide))
theorem d0e1Owner1 : Scope d0e1Outer ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter (d0e1Owner0) "@fast-local:1:0" (by decide))
theorem d0e1Owner2 : Scope d0e1Outer ["@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter ((Scope.enter (Scope.root) "@fast-local:0:0" (by decide))) "@fast-local:0:1" (by decide))
theorem d0e1Owner3 : Scope d0e1Outer ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter (d0e1Owner2) "@fast-local:1:0" (by decide))
def d0Paid : Mapping := [("_q0", "_q3")]
theorem d0PaidOuter : OuterLinks d0e0Outer d0e1Outer d0Paid := (OuterLinks.add (OuterLinks.empty) "_q0" "_q3" (by decide) (by decide))
theorem d0e0Owner0_d0e1Owner0_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner0 d0e1Owner0 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner0_d0e1Owner1_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner0 d0e1Owner1 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner0_d0e1Owner2_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner0 d0e1Owner2 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner0_d0e1Owner3_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner0 d0e1Owner3 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner1_d0e1Owner0_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner1 d0e1Owner0 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner1_d0e1Owner1_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner1 d0e1Owner1 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner1_d0e1Owner2_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner1 d0e1Owner2 d0PaidOuter base source target aLocal bLocal aUse bUse
theorem d0e0Owner1_d0e1Owner3_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d0Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d0e0Owner1 d0e1Owner3 d0PaidOuter base source target aLocal bLocal aUse bUse

def d1e0Outer : List String := ["_q3"]
theorem d1e0Owner0 : Scope d1e0Outer ["@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter ((Scope.enter (Scope.root) "@fast-local:0:0" (by decide))) "@fast-local:0:1" (by decide))
theorem d1e0Owner1 : Scope d1e0Outer ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter (d1e0Owner0) "@fast-local:1:0" (by decide))
theorem d1e0Owner2 : Scope d1e0Outer ["@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter ((Scope.enter (Scope.root) "@fast-local:0:0" (by decide))) "@fast-local:0:1" (by decide))
theorem d1e0Owner3 : Scope d1e0Outer ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0", "_q3"] ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter (d1e0Owner2) "@fast-local:1:0" (by decide))

def d1e1Outer : List String := ["_q0", "_q1"]
theorem d1e1Owner0 : Scope d1e1Outer ["@fast-local:0:1", "@fast-local:0:0", "_q0", "_q1"] ["@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter ((Scope.enter (Scope.root) "@fast-local:0:0" (by decide))) "@fast-local:0:1" (by decide))
theorem d1e1Owner1 : Scope d1e1Outer ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0", "_q0", "_q1"] ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"] := (Scope.enter (d1e1Owner0) "@fast-local:1:0" (by decide))
def d1Paid : Mapping := [("_q3", "_q0")]
theorem d1PaidOuter : OuterLinks d1e0Outer d1e1Outer d1Paid := (OuterLinks.add (OuterLinks.empty) "_q3" "_q0" (by decide) (by decide))
theorem d1e0Owner0_d1e1Owner0_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner0 d1e1Owner0 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner0_d1e1Owner1_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner0 d1e1Owner1 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner1_d1e1Owner0_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner1 d1e1Owner0 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner1_d1e1Owner1_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner1 d1e1Owner1 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner2_d1e1Owner0_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner2 d1e1Owner0 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner2_d1e1Owner1_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner2 d1e1Owner1 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner3_d1e1Owner0_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner3 d1e1Owner0 d1PaidOuter base source target aLocal bLocal aUse bUse
theorem d1e0Owner3_d1e1Owner1_charge (base : Mapping) (source target : Variable)
    (aLocal : source.isLocal = true) (bLocal : target.isLocal = true)
    (aUse : source.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) (bUse : target.name ∈ ["@fast-local:1:0", "@fast-local:0:1", "@fast-local:0:0"]) :
    variableCost (d1Paid ++ base) source target = variableCost base source target :=
  source_scopes_preserve_local_charge d1e0Owner3 d1e1Owner1 d1PaidOuter base source target aLocal bLocal aUse bUse

end RetainedOuterLocalWitnesses
