import edu.mit.csail.sdg.alloy4.*;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.*;
import edu.mit.csail.sdg.translator.*;

public class TemporalCapabilityProbe {
    public static void main(String[] args) throws Exception {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "warn");
        CompModule module = CompUtil.parseEverything_fromFile(A4Reporter.NOP, null, args[0]);
        Command command = module.getAllCommands().stream()
                .filter(c -> c.label.startsWith("CapBenchEquivalent_")).findFirst().orElseThrow();
        for (boolean expose : new boolean[] {false, true}) {
            Command tested = expose ? command.change(command.formula.and(ExprConstant.TRUE.after())) : command;
            A4Options options = new A4Options();
            options.solver = A4Options.SatSolver.SAT4J;
            System.out.println("expose=" + expose + " detected="
                    + CompUtil.isTemporalModel(module.getAllReachableSigs(), tested));
            A4Solution solution = TranslateAlloyToKodkod.execute_command(
                    A4Reporter.NOP, module.getAllReachableSigs(), tested, options);
            System.out.println("counterexample=" + solution.satisfiable()
                    + " bounds=" + solution.getMinTrace() + ".." + solution.getMaxTrace());
        }
    }
}
