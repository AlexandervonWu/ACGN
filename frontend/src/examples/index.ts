import aci from "./aci.als?raw";
import alpha from "./alpha.als?raw";
import prenex from "./prenex.als?raw";
import simple from "./simple.als?raw";
import slots from "./slots.als?raw";

export const examples = { simple, alpha, aci, prenex, slots } as const;
export type ExampleName = keyof typeof examples;

export function requestedExample(): ExampleName {
  const value = new URLSearchParams(window.location.search).get("example");
  return value && value in examples ? (value as ExampleName) : "slots";
}
