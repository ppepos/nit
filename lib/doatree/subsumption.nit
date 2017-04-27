module subsumption

import poset
import doatree

redef class DOATreeIntermediateNode[E]

	# Implements the distribution of the relative complement on a DOATree
	# This works similarly to a tree rotation except the distributed part needs
	# to be deep-copied.
	# ```
	# initial   after distribution
	#     -         &
	#    / \       / \
	#   &   z     -   -
	#  / \       / \ / \
	# x   y     x  z y  z
	# ```
	#
	# TODO: Optimize this to reuse the original Z subtree and the root DiffNode
	# For now they are being copied to reduce possible side effects while we
	# are still unsure of the correctness of the algorithm
	fun distribute(parent: nullable DOATreeNode[E]): DOATreeNode[E]
	do
		var pivot = self.left

		# Base case: Stop recursing when we distributed to all intermediate nodes
		if pivot isa DOATreeElementNode[E] then return self

		assert pivot isa DOATreeIntermediateNode[E]
		var x = pivot.left
		var y = pivot.right

		# Copy the right side of the operation
		# so we can hook it up in multiple places in the tree
		var z_left = self.right.copy
		var z_right = self.right.copy

		var left_diff = new DOATreeDiffNode[E](x, z_left)
		var right_diff = new DOATreeDiffNode[E](y, z_right)

		pivot.left = left_diff.distribute(self)
		pivot.right = right_diff.distribute(self)

		return pivot
	end
end

redef class DOATreeNode[E]

	fun is_substituable(poset: POSet[E]): Bool
	do
		return simplify(poset) == null
	end

	fun simplify(poset: POSet[E]): nullable E is abstract
end

redef class DOATreeDiffNode[E]
	redef fun simplify(poset)
	do
		var left = self.left
		var right = self.right
		assert left isa DOATreeElementNode[E]
		assert right isa DOATreeElementNode[E]

		var is_subclass = poset.has_edge(left.element, right.element)

		if is_subclass then
			return null
		else
			return left.element
		end
	end
end

redef class DOATreeOrNode[E]
	redef fun simplify(poset)
	do
		var left = self.left
		var right = self.right
		assert left isa DOATreeIntermediateNode[E]
		assert right isa DOATreeIntermediateNode[E]

		var left_res = left.simplify(poset)
		var right_res = right.simplify(poset)

		if left_res == null and right_res == null then return null

		# This is inexact
		return left_res
	end
end

redef class DOATreeAndNode[E]
	redef fun simplify(poset)
	do
		var left = self.left
		var right = self.right
		assert left isa DOATreeIntermediateNode[E]
		assert right isa DOATreeIntermediateNode[E]

		var left_res = left.simplify(poset)
		var right_res = right.simplify(poset)

		if left_res == null or right_res == null then return null

		# This is inexact
		return left_res
	end
end
