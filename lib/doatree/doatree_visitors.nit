module doatree_visitors

import doatree

abstract class DOATreeNodeVisitor[E]
	fun visit(n: DOATreeNode[E]) is abstract
end

class DOATreeNodePrintVisitor[E]
	super DOATreeNodeVisitor[E]

	redef fun visit(n)
	do
		n.accept_print_visitor(self)
	end
end

class DOATreeNodeDotVisitor[E]
	super DOATreeNodeVisitor[E]

	var out = "" is writable
	var node_count = 0

	redef fun visit(n)
	do
		n.accept_dot_visitor(self)
	end

	fun writeout
	do
		print "digraph doatree \{\n{out}\}"
	end
end

redef class DOATreeNode[E]

	fun accept_print_visitor(v: DOATreeNodePrintVisitor[E]) do end

	fun accept_dot_visitor(v: DOATreeNodeDotVisitor[E]) do end
end

redef class DOATreeDiffNode[E]

	redef fun accept_print_visitor(v)
	do
		printn "("
		v.visit(self.left)
		printn " \\ "
		v.visit(self.right)
		printn ")"
	end

	redef fun accept_dot_visitor(v)
	do
		v.out += "{object_id} [label=\"\\\\\"]\n"
		v.visit(self.left)
		v.visit(self.right)
		v.out += "{object_id} -> {self.left.object_id};\n"
		v.out += "{object_id} -> {self.right.object_id};\n"
	end
end

redef class DOATreeOrNode[E]
	redef fun accept_print_visitor(v)
	do
		printn "("
		v.visit(self.left)
		printn " | "
		v.visit(self.right)
		printn ")"
	end

	redef fun accept_dot_visitor(v)
	do
		v.out += "{object_id} [label=\"∨\"]\n"
		v.visit(self.left)
		v.visit(self.right)
		v.out += "{object_id} -> {self.left.object_id};\n"
		v.out += "{object_id} -> {self.right.object_id};\n"
	end
end

redef class DOATreeAndNode[E]
	redef fun accept_print_visitor(v)
	do
		printn "("
		v.visit(self.left)
		printn " & "
		v.visit(self.right)
		printn ")"
	end

	redef fun accept_dot_visitor(v)
	do
		v.out += "{object_id} [label=\"∧\"]\n"
		v.visit(self.left)
		v.visit(self.right)
		v.out += "{object_id} -> {self.left.object_id};\n"
		v.out += "{object_id} -> {self.right.object_id};\n"
	end
end

redef class DOATreeElementNode[E]
	redef fun accept_print_visitor(v)
	do
		printn self.element or else "_"
	end

	redef fun accept_dot_visitor(v)
	do
		v.out += "{object_id} [label=\"{self.element or else "null"}\"]\n"
	end
end
