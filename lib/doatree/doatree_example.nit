module doatree_example

import doatree

var a_node = new DOATreeElementNode[String](null, "A")
var b_node = new DOATreeElementNode[String](null, "B")

var and_node = new DOATreeAndNode[String]
and_node.left = a_node
and_node.right = b_node
a_node.parent = and_node
b_node.parent = and_node

var c_node = new DOATreeElementNode[String](null, "C")
var d_node = new DOATreeElementNode[String](null, "D")

var or_node = new DOATreeOrNode[String]
or_node.left = c_node
or_node.right = d_node
c_node.parent = or_node
d_node.parent = or_node

var diff_node = new DOATreeDiffNode[String]
diff_node.left = and_node
diff_node.right = or_node
or_node.parent = diff_node
and_node.parent = diff_node

var tree = new DOATree[String](diff_node)
print tree
