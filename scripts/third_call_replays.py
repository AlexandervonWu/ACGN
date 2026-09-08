"""P1-06/P1-09/P1-16 finite correspondence plugin; no closure authority.

The aggregator may delegate generate(build, formal), negatives(build, formal),
and source_mutations(). Only this module's two named TSVs are read. Source and
every observed target are encoded separately with an injective joint token map.
"""

import copy
import csv
import json
from pathlib import Path
import re

from run_submission_container_closure import Blocked

CALL_ARITIES = (0, 1, 2, 3, 5, 8, 16)
CALL_CENSUS = {**{f"arity-{n}": 8 for n in CALL_ARITIES}, "nested": 30, "imported": 5}
CALL_OCCURRENCES = 91
CALL_SOURCE_COUNT = 43
CALL_FIELDS = ("schema fixture occurrence owner visit signature_table declaration_groups declared_signature "
               "parser_tree masg_tree ir_tree cert_tree before first_visit first_after first_accept "
               "second_visit second_after second_accept max_visit ir_arity ir_policy cert_path observation_sha256").split()
CALL_SOURCE_FIELDS = "object owner method arity shapeSha256 bindingsSha256 model".split()
CALL_TRACE = "call-authority.tsv"
CALL_SOURCE_TRACE = "call-authority-source.tsv"
CALL_REPLAY = "CallAuthorityReplay.lean"
REPLAY_NAMESPACE = "ACGN.ThirdFive.CallReplay"
KINDS = {"call/formula": 0, "call/expression": 1}
AUTHORITIES = {"DECLARATION": 0, "TYPECHECKED_IMPORT": 1}
TREE_FIELDS = ("parser_tree", "masg_tree", "ir_tree", "cert_tree")
NAT_FIELDS = ("occurrence owner visit before first_visit first_after second_visit second_after max_visit ir_arity").split()
# Frozen source object records, not a learn-current-source mode. Field arity -1
# identifies the checked SIGNATURES initializer; all other arities count parameters.
CALL_SOURCE_OBJECTS = {
    "visitor-reset": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "visit", "2", "73683c3b95ce9da53c0b653390f017c5b82dc4dbdb00feff4a4595354067718b", "e89e776f9598f418930d95d58bbda398be1edcea28aab4313d884e21faab2c0e", "resolve"),
    "declaration-index": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "indexCallableDeclarations", "1", "1b4df432580f2c90db961cf0a7a9cba309a9b6eaef82694e4d1884ac319b69c3", "692bdee7e6a5240a7ac6328281fd19e108fe6f982de03094b858ae30d880fa2b", "resolve"),
    "declaration-register": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "registerCallable", "2", "d6a6382bf5a7aadc1c7ddd88d14a0ed946ba0ba6560fee198c32d3668e428fc0", "899e2be9854bcfc032ff399016e68d1e4fc1a78e3e386dad43cdd51cc71faa22", "resolve"),
    "declaration-alias": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "putCallableAlias", "2", "b7ac72cbccb6ff3d1181abc77fe99ef9a5f3104e3d3771b9bc71ca58b5633b09", "b39f31703b09793e494a7bce10682db5314714a2801fd149cb90e38203826b11", "resolve"),
    "declaration-arity": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "declaredArity", "1", "cd052b0803af2564fc0d29aa6fed793c1756fbadb62449709b4ce62b6afd9752", "3331299a9ac07de21b3e0342ec8833545d0232265c8e4c2f9a80324f2000eece", "declaredArity"),
    "declaration-find": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "findDeclaredCallable", "3", "187102482436b85f9d4baa8189d1e331a15765ec14e4f6ceae52dfa436df71ec", "ce306c8158356cfa573fae8f00d5535fe6fc1662b84752919fb1fe22d45de03d", "resolve"),
    "declaration-resolve": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "resolveCallable", "3", "7c60f840f187c4ddf540075a02fe9f1222bf38cf3bf25a43f9be64b1528df13e", "c943c1ea8f86971372c218ca4e29277126531288406f86100cbae6aad2d7c479", "resolve"),
    "declaration-descriptor": ("is.fivefivefive.ACGN.visitor.MASGVisitor.CallableDescriptor", "<init>", "5", "14e084adcdc05c2cb0327ebe626487cb5ae7bcb1a37e0529650cbe3e2f59ac43", "19704f05cad6deb2185f92fa5cdd384329546c6fb19106a3e3b825f6bfa91865", "resolve"),
    "import-resolve": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "importedCallable", "1", "36a5212061bbfe89e3aa0d463bbe86f8f82a89f8fbdec5f37e4ce03e6087b9c8", "84c9502f51118aad90625b37998d967ad6c40839fa77fdcbd81e020e6412ab57", "resolve"),
    "import-alias": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "registerImportedAlias", "2", "ab34dcd38724704434a44c91fb77dbdefaa903ea02eb84bcbb82d7512fe5c6af", "3e224eae477c2bf18581842ee72c7eb9fb71d3e0a568e76242a4dd1a7ec43665", "resolve"),
    "ledger-state": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "SIGNATURES", "-1", "02f72e1a1375f8b40a32e5956e52a5deb042b63e863d37149a0ced5eb392b1b2", "406d84bbb778dbabc490316e14e9de65c71f7b4e547623119443e7a75006db56", "resolve"),
    "ledger-table": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "signatures", "0", "0cdb2e012692c77d55b05c320990cb7a90c438e32c037f2968dab670ca5fa45c", "2248fc6421ef7be0c3dbfc85a6b90cebe0326796b4d1d3cdd36a473f0d01078f", "resolve"),
    "ledger-require": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "require", "4", "41f3f492fad4e97e26fab42b28be6f17e21681ef7e1943692155c3501aff3ce6", "cc1d4a95ceee19a8206163cee89ca904d5e6bb7d50edc44a55de7ae1905eee83", "resolve"),
    "ledger-key": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "key", "4", "1a6bca531c66367bf3d68dcdcd6cd173ff4638408cbbb9a90ce5365390b1ca54", "cc7de580c69bbb4b90bd293eb9d2463bc0cf93fef8a7c97f1cce37d2afab8844", "resolve"),
    "ledger-put": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "put", "5", "eb33bd79bf64dbe383b3957b52640f1356a788a549a51edaf308505e564b02cd", "0a25bcde0e5fec9bab6789805792c3fee306c1b46f14761bef8750163524e453", "resolve"),
    "ledger-expression": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "expression", "4", "15e02fe527327eb4f151ae2338b6ed316363051c3287a8d9509eb04576068ab5", "7686c7887c130504c227023d88ea59ddf8b24b5eaad38e939536ca3f13f9440f", "resolve"),
    "ledger-formula": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger", "formula", "4", "83cf28e668266dc4051a6cc36d4fb15878d636aab584f8b5f4b77aee0a56501d", "1984689fe579b8a45a511aa86607fabdbbb1a4930febdf86b05047a4da77e62c", "resolve"),
    "signature-init": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger.Signature", "<init>", "2", "f92a5f16aef4908457d8d38f173a15e60010379fa6716a618d46b0f85c0b94a4", "1a859397e5d678ee90ddfc40c9723af449b273b304ca4af77453220f6aafa30c", "resolve"),
    "signature-arity": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger.Signature", "arity", "0", "216753480b5878f5179d3d4747980828af15e05b845bb7852ff41065dd3d8639", "a6e1ccf1ba6034281718f0fa92d0b7c35d0b80dcfcf32aa29aeb749ba44f0528", "resolve"),
    "signature-kind": ("is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger.Signature", "kind", "0", "8d47123c1b2fada11e3c1ba243ff1a8105455fa1b794dfbb0df80b45b9e616b0", "e66541832c00204b0778ec3e0267451b6acb0446e094883e3e34526f8752b4a6", "resolve"),
    "call-init": ("is.fivefivefive.ACGN.alloy.CallSymbol", "<init>", "6", "d2f1c1f184cde4d8ba813e08973958cca9b84df8adaccf81a88c0401e87a07a8", "3ab762e6702fe3435e65465094ae6f6fc56346df8e0244bc8f9cb110fafa89da", "resolve"),
    "call-arity": ("is.fivefivefive.ACGN.alloy.CallSymbol", "getDeclaredArity", "0", "98749e545b911638540cd3b407b3b4b7d666f5df126cc8c42bbe6d8ec1e9320b", "72b0e4717c7c3998d7f675e38c1bf019041089ad85218a42377e7cf339bac79c", "resolve"),
    "call-authority": ("is.fivefivefive.ACGN.alloy.CallSymbol", "getArityAuthority", "0", "00638cd2844378ebc68f60b6951bd93bea8b5d5131f9e0f5cee4e7f058a27452", "3c5193e40de49d3df9e79133c1b2199ff643b62a1925b1ef1d949a5e27a9ccc3", "resolve"),
    "call-occurrence": ("is.fivefivefive.ACGN.alloy.CallSymbol", "getOccurrenceId", "0", "8051debd4c00af859bb3859cae336cd2d21aaed4b9c9fb8e4d79e586b52c525f", "14f7a4ec7fd3b9fdd0bccb4839ed0f840f0952edba3306acd0a268e0587912a4", "consume"),
    "visitor-call": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "visitCall", "4", "cff919b971bb71660927853efb261a65abe6f48411a62f3dcbc34c9d0b28788f", "76c882982b9c3e21f4d49eccbd8b15ec40a0acc6f371442010cf276cc3d9b701", "lower"),
    "visitor-capture": ("is.fivefivefive.ACGN.visitor.MASGVisitor.CallVisitCapture", "<init>", "3", "c74ace5d90a939855bab500f6a37275a3b2edeced7993b942174e1a804749926", "282cf5ac3e9c0b14db21d75e32943441ef9be42ad8dab60c87c0dfef5721e1a7", "consume"),
    "visitor-time": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "updateTimeOfVisit", "2", "900df7caf5565593a73f3bb20efe1cdbcfdae4d23d20a83b8041c6d397d3d3bb", "471597317b0132b2bc8c9adcc6107c34676ae74770aa0d5ccfb1935bba1f6b1d", "consume"),
    "counter-step": ("is.fivefivefive.CanDis.ir.IRAgent", "nextTov", "2", "12aa5e443728d10bb0a6943e331848d47e2f162bbb42c3a0be1050c7bb9b44f5", "3bc21ce8b86aaa8b387bbcf4faff31bf9a2a5f96fc4974d2917ab8b6dc0c1b6f", "advance"),
    "visit-select": ("is.fivefivefive.CanDis.ir.IRAgent", "downlinksFor", "3", "2ef01c475fafe71a8ef3147e060a39994fb7be4c6fcd5eb7bbd820c6fc1fb749", "abb9cbe0df10caeee4054872582cbdb7192462e84e16e9d291f86a9274afda03", "consume"),
    "visit-validate": ("is.fivefivefive.CanDis.ir.IRAgent", "validateCallDownlinks", "3", "e31285d22293db48dc79371b9a1356921f396fc45d8bdc675331daacdce52c1b", "f3f9239e2a1cde4517a8b6c7cc752c4cfa4f957441faabcef9241b3df811abde", "consume"),
    "ir-build": ("is.fivefivefive.CanDis.ir.IRAgent", "buildEGraph", "7", "208277c8f3a1b5b478af357aec94e025cfaffae629d26804cb245fee19b469a8", "9fc429a3d13bba99523297e44d18929bd39093379a9924fb8bd37e1936c0d35a", "lower"),
    "ir-metadata": ("is.fivefivefive.CanDis.ir.IRAgent", "attachSourceMetadata", "3", "e759a23b19b2202140a66ad981d9eb1939b550619938b85f52eac7aa13c9d66c", "076a961620d57ebda4f35a7a329373e3db8f3cdab42ac9a5d29c07379d20a60d", "resolve"),
    "metadata-require": ("is.fivefivefive.CanDis.core.CallMetadata", "require", "1", "69401097cfad53a7ec8c5b70ca96194e670b61fcb6202223ecf8f93451c538ec", "d446b5a1a33b8b09c53c5cb9c736eba858e4984fff54a55a0ce245a63ffbaef3", "resolve"),
    "call-policy": ("is.fivefivefive.CanDis.core.AlloyOperatorPolicy", "forShape", "4", "6c40534b36a68b02d76f2bfb4fe81a34da3476f8bbe5c5a180c2f18e8cd1b908", "fe86e671b326be1e6bdac868a85a4bfedc5ac8c3a891081426b7ae4c699b9326", "lower"),
    "policy-nonflat": ("is.fivefivefive.CanDis.core.AlloyOperatorPolicy", "nonflat", "2", "bf8585a75accaa2103553160a214a177bf978ae5e561514d830b47bcfa930908", "298778f57cdb1570636cc6b70aebff3111f0c540743e7dc0cb7087913aa20e03", "lower"),
    "ir-policy": ("is.fivefivefive.CanDis.core.EGraphNode", "operatorPolicy", "0", "6aeb9f71ca0c8dcf971817d7bfdc962697607b4f0dd31fbf9bccfd757b51333c", "18f806312715ae3915697a3c8df612dce436c58b8021daf156f076ddd6450076", "lower"),
    "ir-append": ("is.fivefivefive.CanDis.core.EGraphNode", "appendChild", "2", "94a65db193bac0473708e78a2d814fd3379e1f801e4f6e55255fd62d4e2e159a", "1f3c8d04816ac7396ab05e70a3f9a2e947b03f5f009f3d427ba621076a6916d2", "lowerArgs"),
    "ir-sort-key": ("is.fivefivefive.CanDis.core.EGraphNode", "appendSortKey", "2", "2c3e8cf84f2c659112c951642a3f4d39a207e30c2f53c2bf4a2c63536ac3ebca", "eb1d69a7414586430ee8f687002b9fcb599ef76c1d807dda08930884c31289aa", "lowerArgs"),
    "ir-semantic-head": ("is.fivefivefive.CanDis.core.EGraphNode", "appendSemanticHead", "2", "7722aba5ffd35631ef67b057f90e05fc3ba65eb436d660110bf48126de099ab2", "aff92b0f97fa6e3a341443fa948562a93ce60ce3ec6ebb50e43d2bd0fe9cd2f8", "lower"),
    "adapter-operands": ("is.fivefivefive.CanDis.theory.TheoryAlloyAdapter.Builder", "buildOperand", "5", "ef797f2df65b535d8c16c813edf7a6cfa10be15d43a63ae854286f25f7d63eeb", "b58add826ea5961bfdff8eec4f7b4b632d56a35146d3759573ab5f1abda8fcec", "lowerArgs"),
    "adapter-node": ("is.fivefivefive.CanDis.theory.TheoryAlloyAdapter.Builder", "constructNode", "3", "5f695bebc5f200fc17a889b47ce5b0aad05cbc80753e6f2e9c8004922b42ee58", "1c1f9354ef01980ea0c097063310fc5084143f2a981e45967b1b6054b6e99396", "lower"),
    "adapter-head": ("is.fivefivefive.CanDis.theory.TheoryAlloyAdapter", "semanticHead", "1", "21694899b06e2b1c236a5675edd0468b3b209497ef8129124aa3f29234bd8372", "1b7e8b8231ae3661093cf163a7bca9f7e8856f5ee9d83de7633a8ab53af2a2b6", "lower"),
    "certificate-binding": ("is.fivefivefive.CanDis.theory.CallOccurrenceCertificate", "requireExactBinding", "0", "296e271c33884c7268fa43bed75a4666e42bbde703c74cedf8534a2e8b0545ec", "942f842d37e2ff848fe42f7d9efd734de65edbe7c3402cde020ed03d186316aa", "checkRepresentation"),
}


def require(ok, message):
    if not ok:
        raise Blocked("CALL_AUTHORITY: " + message)


def rows(path, fields):
    with Path(path).open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        require(reader.fieldnames == fields, "unexpected TSV schema: " + str(path))
        result = list(reader)
    require(result, "empty TSV: " + str(path))
    for row in result:
        require(set(row) == set(fields) and all(isinstance(v, str) and not any(ord(c) < 32 for c in v)
                for v in row.values()), "malformed TSV row")
    return result


def natural(value):
    require(isinstance(value, str) and re.fullmatch(r"0|[1-9][0-9]{0,18}", value), "noncanonical natural")
    return int(value)


def nat_json(value):
    require(type(value) is int and 0 <= value < 10**19, "invalid JSON natural")
    return value


def visible(value):
    require(isinstance(value, str) and value and len(value) <= 4096
            and all(ord(c) >= 32 for c in value), "invalid nominal token")
    return value


def decode(value):
    try:
        result = json.loads(value, parse_constant=lambda _: (_ for _ in ()).throw(ValueError("nonfinite")))
    except (ValueError, TypeError, RecursionError) as error:
        raise Blocked("CALL_AUTHORITY: malformed JSON") from error
    return result


def signature(value):
    require(isinstance(value, list) and len(value) == 4, "signature field census")
    callee, kind, arity, authority = value
    visible(callee)
    require(isinstance(kind, str) and kind in KINDS and isinstance(authority, str)
            and authority in AUTHORITIES, "unknown explicit kind/authority")
    return callee, kind, nat_json(arity), authority


def tree(value, depth=0):
    require(depth <= 128 and isinstance(value, list) and value, "invalid/bounded tree syntax")
    if value[0] == "atom":
        require(len(value) == 2, "atom field census")
        nat_json(value[1])
    else:
        require(value[0] in ("call", "barrier") and len(value) == 3
                and isinstance(value[2], list) and len(value[2]) <= 64, "branch field census")
        if value[0] == "call":
            signature(value[1])
        else:
            visible(value[1])
        for child in value[2]:
            tree(child, depth + 1)
    return value


def validate_source(extracted):
    require(len(extracted) == CALL_SOURCE_COUNT == len(CALL_SOURCE_OBJECTS), "source census")
    seen = set()
    for row in extracted:
        key = row["object"]
        require(key in CALL_SOURCE_OBJECTS and key not in seen, "missing/duplicate source object")
        seen.add(key)
        actual = tuple(row[field] for field in CALL_SOURCE_FIELDS[1:])
        require(actual == CALL_SOURCE_OBJECTS[key], "unregistered source structure/resolution: " + key)


def parsed_row(row):
    require(set(row) == set(CALL_FIELDS), "observation field census")
    for field in NAT_FIELDS:
        natural(row[field])
    require(row["first_accept"] in ("true", "false") and row["second_accept"] in ("true", "false"), "nonboolean outcome")
    require(row["schema"] == "call-authority-v1" and row["ir_policy"] == "ORDERED_SEQUENCE", "schema/carrier changed")
    require(re.fullmatch(r"[0-9a-f]{64}", row["observation_sha256"]), "invalid observation digest")
    visible(row["cert_path"])
    table = decode(row["signature_table"])
    require(isinstance(table, list) and table and len(table) <= 128, "signature table census")
    signatures = [signature(s) for s in table]
    require(len(set(signatures)) == len(signatures), "duplicate authority table row")
    groups = decode(row["declaration_groups"])
    require(isinstance(groups, list) and len(groups) <= 64, "parameter groups census")
    for group in groups:
        nat_json(group)
    selected = signature(decode(row["declared_signature"]))
    trees = {field: tree(decode(row[field])) for field in TREE_FIELDS}
    require(all(t[0] == "call" for t in trees.values()), "occurrence root is not CALL")
    return signatures, groups, selected, trees


def validate_rows(observed):
    expected = {(fixture, i) for fixture, count in CALL_CENSUS.items() for i in range(count)}
    require(len(observed) == CALL_OCCURRENCES == len(expected), "occurrence census")
    seen = set()
    owners = set()
    tables = {}
    for row in observed:
        ident = row["fixture"], natural(row["occurrence"])
        require(ident in expected and ident not in seen, "unknown/duplicate occurrence")
        seen.add(ident)
        owner = row["fixture"], natural(row["owner"])
        require(owner not in owners, "duplicate actual captured owner")
        owners.add(owner)
        table, _, selected, _ = parsed_row(row)
        if row["fixture"].startswith("arity-"):
            require(selected[2] == int(row["fixture"][6:]), "declared fixture arity changed")
        require(tables.setdefault(row["fixture"], table) == table, "inconsistent independent authority table")
    require(seen == expected, "missing occurrence")


def lean_list(values):
    return "[" + ", ".join(map(str, values)) + "]"


class Encoder:
    def __init__(self, values):
        callees, barriers = set(), set()

        def collect(node):
            if node[0] == "call":
                callees.add(signature(node[1])[0])
            elif node[0] == "barrier":
                barriers.add(node[1])
            if node[0] != "atom":
                for child in node[2]:
                    collect(child)

        for table, _, selected, trees in values:
            callees.update(s[0] for s in table)
            callees.add(selected[0])
            for node in trees.values():
                collect(node)
        # Extend across input AND every target, including previously unseen wrong keys.
        self.callees = {value: i for i, value in enumerate(sorted(callees))}
        self.barriers = {value: i for i, value in enumerate(sorted(barriers))}

    def sig(self, value):
        callee, kind, arity, authority = value
        return f"(Signature.mk {self.callees[callee]} {KINDS[kind]} {arity} {AUTHORITIES[authority]})"

    def term(self, value, target=False):
        if value[0] == "atom":
            return f"(.{'scalar' if target else 'atom'} {value[1]})"
        args = lean_list(self.term(child, target) for child in value[2])
        vector = f"({'ports' if target else 'sourceArgs'} {args})"
        if value[0] == "call":
            return f"(.{'application' if target else 'call'} {self.sig(signature(value[1]))} {vector})"
        return f"(.{'boundary' if target else 'barrier'} {self.barriers[value[1]]} {vector})"


def row_body(row, parsed, encoder, index):
    table, groups, selected, trees = parsed
    source_key = signature(trees["parser_tree"][1])
    callee, kind, _, _ = source_key
    observed_arity = len(trees["parser_tree"][2])
    body = [f"def table{index} : List Signature := {lean_list(encoder.sig(s) for s in table)}",
            f"def declaration{index} : Signature := {encoder.sig(selected)}",
            f"def source{index} : Source := {encoder.term(trees['parser_tree'])}"]
    for field in TREE_FIELDS[1:]:
        body.append(f"def {field}{index} : Representation := {encoder.term(trees[field], target=True)}")
    clauses = [f"resolve table{index} {encoder.callees[callee]} {KINDS[kind]} {observed_arity} = some declaration{index}",
               f"declaration{index} = {encoder.sig(source_key)}", f"JavaAritySafe declaration{index}.arity",
               f"({natural(row['ir_arity'])} : Nat) = declaration{index}.arity"]
    if selected[3] == "DECLARATION":
        clauses.append(f"declaration{index}.arity = declaredArity {lean_list(groups)}")
    else:
        require(groups == [], "import must not pretend to be a parser parameter declaration")
    clauses.extend(f"checkRepresentation source{index} {field}{index} = true" for field in TREE_FIELDS[1:])
    before, first, after, second, second_after, maximum, visit = [natural(row[field]) for field in
            ("before", "first_visit", "first_after", "second_visit", "second_after", "max_visit", "visit")]
    valid = f"(fun v => decide (v = {visit}))"
    first_result = f"some {first}" if row["first_accept"] == "true" else "none"
    second_result = f"some {second}" if row["second_accept"] == "true" else "none"
    owner = natural(row["owner"])
    clauses.extend([f"consume {before} {maximum} {valid} = ({after}, {first_result})",
                    f"consume {after} {maximum} {valid} = ({second_after}, {second_result})",
                    f"allocations (fun _ => {before}) [{owner}, {owner}] = [({owner}, {first}), ({owner}, {second})]",
                    f"JavaStepSafe {before}", f"JavaStepSafe {after}",
                    f"({before} : Nat) = 0", f"({visit} : Nat) = 1", f"({maximum} : Nat) = 1"])
    body.extend([f"theorem call{index} : " + " ∧\n    ".join(clauses) + " := by decide",
                 f"#print axioms call{index}"])
    return "\n".join(body)


def module(observed):
    values = [parsed_row(row) for row in observed]
    encoder = Encoder(values)
    return ("import CallAuthorityTransitions\nopen ACGN.ThirdFive.CallAuthorityTransitions\n"
            f"namespace {REPLAY_NAMESPACE}\nset_option maxRecDepth 4096\n"
            + "\n".join(row_body(row, value, encoder, i) for i, (row, value) in enumerate(zip(observed, values)))
            + f"\nend {REPLAY_NAMESPACE}\n")


def call_program(observed, extracted):
    validate_source(extracted)
    validate_rows(observed)
    return module(observed), CALL_OCCURRENCES


def generate(build, formal):
    source, count = call_program(rows(Path(build) / CALL_TRACE, CALL_FIELDS),
                                 rows(Path(build) / CALL_SOURCE_TRACE, CALL_SOURCE_FIELDS))
    return [(CALL_REPLAY, source, count)]


def negatives(build, formal):
    observed = rows(Path(build) / CALL_TRACE, CALL_FIELDS)
    extracted = rows(Path(build) / CALL_SOURCE_TRACE, CALL_SOURCE_FIELDS)
    validate_source(extracted)
    validate_rows(observed)
    result = []

    def changed(label, original, mutate):
        row = copy.deepcopy(original)
        mutate(row)
        # Full isolated module, including namespace close. Rejection must be a
        # false target proposition, never a slice's syntax/import failure.
        result.append(("call-" + label, "RejectCallAuthority.lean", module([row])))

    def edit_tree(row, field, edit):
        value = decode(row[field])
        edit(value)
        row[field] = json.dumps(value, separators=(",", ":"))

    first = observed[0]
    for field in TREE_FIELDS[1:]:
        changed("foreign-" + field, first, lambda row, f=field: edit_tree(row, f, lambda t: t[1].__setitem__(0, "foreign/callee")))
    changed("wrong-authority", first,
            lambda row: edit_tree(row, "ir_tree", lambda t: t[1].__setitem__(3, "TYPECHECKED_IMPORT")))
    changed("counter-no-advance", first, lambda row: row.update(first_after="0"))
    changed("consumed-reaccepted", first, lambda row: row.update(second_accept="true"))
    changed("visit-reused", first, lambda row: row.update(second_visit="1", second_after="1", second_accept="true"))
    changed("int-overflow-premise", first, lambda row: row.update(before="2147483647"))

    def replace_authority(row):
        table = decode(row["signature_table"])
        selected = decode(row["declared_signature"])
        table[table.index(selected)][2] = max(s[2] for s in table) + 1
        row["signature_table"] = json.dumps(table)
    changed("observed-cannot-replace-table", first, replace_authority)
    repeated = next(row for row in observed if len(decode(row["cert_tree"])[2]) == 2
                    and decode(row["cert_tree"])[2][0] == decode(row["cert_tree"])[2][1])
    changed("deduplicated-ports", repeated,
            lambda row: edit_tree(row, "cert_tree", lambda t: t[2].pop()))
    ordered = next(row for row in observed if len(decode(row["cert_tree"])[2]) == 2
                   and decode(row["cert_tree"])[2][0] != decode(row["cert_tree"])[2][1])
    changed("swapped-ports", ordered,
            lambda row: edit_tree(row, "cert_tree", lambda t: t[2].reverse()))
    nested = next(row for row in observed if len(decode(row["cert_tree"])[2]) == 1
                  and decode(row["cert_tree"])[2][0][0] == "call")
    changed("flattened-call", nested,
            lambda row: edit_tree(row, "cert_tree", lambda t: t.__setitem__(2, t[2][0][2])))
    barrier = next(row for row in observed if len(decode(row["cert_tree"])[2]) == 1
                   and decode(row["cert_tree"])[2][0][0] == "barrier")
    changed("erased-barrier", barrier,
            lambda row: edit_tree(row, "cert_tree", lambda t: t[2].__setitem__(0, t[2][0][2][0])))
    return result


def source_mutations():
    visitor = "src/is/fivefivefive/ACGN/visitor/MASGVisitor.java"
    ir = "src/is/fivefivefive/CanDis/ir/IRAgent.java"
    ledger = "src/is/fivefivefive/ACGN/alloy/AlloyLibraryCallableLedger.java"
    symbol = "src/is/fivefivefive/ACGN/alloy/CallSymbol.java"
    extractor = "CallAuthorityTransitionsExtractor"
    return [
        ("call-grouped-declaration-arity", visitor, "arity += declaration.getNames().size();", "arity += 1;", extractor),
        ("call-import-observed-arity", visitor, "signature.arity(),", "observedArity,", extractor),
        ("call-synthesized-ledger-entry", ledger,
         "Signature signature = SIGNATURES.get(key(\n                module, member, expectedKind, observedArity));",
         "Signature signature = new Signature(observedArity, expectedKind);", extractor),
        ("call-shared-arity-state", symbol, "private final int declaredArity;", "private static int declaredArity;", extractor),
        ("call-counter-no-increment", ir, "int tov = tovTracker.getOrDefault(node, 0) + 1;",
         "int tov = tovTracker.getOrDefault(node, 0);", extractor),
        ("call-reuse-guard-omitted", ir, "if (tov > maxTov) {", "if (false && tov > maxTov) {", extractor),
        ("call-reversed-arguments", ir, "AugmentedNode argument = downlinks.get(index).getTarget();",
         "AugmentedNode argument = downlinks.get(call.getDeclaredArity() - index + 1).getTarget();", extractor),
        ("call-skipped-repeats", ir, "int index = 1; index <= call.getDeclaredArity(); index++",
         "int index = 1; index <= call.getDeclaredArity(); index += 2", extractor),
        ("call-erased-nesting", ir, "return current;\n        }\n\n        TemporalOp[] temporalOps",
         "return current.getChildren().get(0);\n        }\n\n        TemporalOp[] temporalOps", extractor),
        ("call-commutative-policy", "src/is/fivefivefive/CanDis/core/AlloyOperatorPolicy.java",
         "if (opcode == Opcode.CALL) {\n            return nonflat(\n                    ArityPolicy.exact(requireFixed(fixedArity)),\n                    SiblingQuotient.ORDERED_SEQUENCE);",
         "if (opcode == Opcode.CALL) {\n            return nonflat(\n                    ArityPolicy.exact(requireFixed(fixedArity)),\n                    SiblingQuotient.COMMUTATIVE_IDEMPOTENT_SET);", extractor),
    ]
