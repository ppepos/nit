import poset
import doatree
import doatree_visitors
import subsumption


# Simple class hierarchy
var poset = new POSet[String]
poset.add_edge("A", "O")
poset.add_node("N")
assert poset.has_edge("A", "O")

var o_node = new DOATreeElementNode[String]("O")
var a_node = new DOATreeElementNode[String]("A")
var n_node = new DOATreeElementNode[String]("N")

var right_node = new DOATreeElementNode[String]("A")

var or_node = new DOATreeOrNode[String](a_node, n_node)
var and_node = new DOATreeAndNode[String](o_node, or_node)

# O & (A|N) <: A ==> (O & (A|N)) \ A == _|_ ??
var diff_node = new DOATreeDiffNode[String](and_node, right_node)
var question_tree = new DOATree[String](diff_node)

var root_node = question_tree.root
assert root_node isa DOATreeDiffNode[String]

root_node = root_node.distribute
print root_node.is_substituable(poset)
