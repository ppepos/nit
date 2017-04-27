module doatree

class DOATree[E]
	super Collection[E]
	var root: DOATreeNode[E]

	init
	do
		root.is_root = true
	end

	fun copy: DOATree[E]
	do
		var root = self.root.copy
		var copy = new DOATree[E](root)
		return copy
	end
end

class DOATreeNode[E]
	# Reference to the parent node
	# var parent: nullable DOATreeNode[E] is writable
	var is_root = false is writable

	fun copy: DOATreeNode[E] is abstract
end

class DOATreeElementNode[E]
	super DOATreeNode[E]

	var element: E

	redef fun copy: DOATreeNode[E]
	do
		var copy = new DOATreeElementNode[E](element)
		return copy
	end
end

class DOATreeIntermediateNode[E]
	super DOATreeNode[E]

	# Reference to `self`'s left child
	var left: DOATreeNode[E] is writable

	# Reference to `self`'s right child
	var right: DOATreeNode[E] is writable
end

# Node class used to represent relative complement (aka difference)
# between its `left` and `right` children.
class DOATreeDiffNode[E]
	super DOATreeIntermediateNode[E]

	redef fun copy: DOATreeNode[E]
	do
		var left = self.left.copy
		var right = self.right.copy
		var copy = new DOATreeDiffNode[E](left, right)
		return copy
	end
end

# Node class used to represent union
# between its children.
class DOATreeOrNode[E]
	super DOATreeIntermediateNode[E]

	redef fun copy: DOATreeNode[E]
	do
		var left = self.left.copy
		var right = self.right.copy
		var copy = new DOATreeOrNode[E](left, right)
		return copy
	end
end

# Node class used to represent intersection
# between its children.
class DOATreeAndNode[E]
	super DOATreeIntermediateNode[E]

	redef fun copy: DOATreeNode[E]
	do
		var left = self.left.copy
		var right = self.right.copy
		var copy = new DOATreeAndNode[E](left, right)
		return copy
	end
end
