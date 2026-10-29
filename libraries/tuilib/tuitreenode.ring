# Node in a TUITreeView

class TUITreeNode

	cText = ""
	aChildren = []
	lExpanded = false
	oParent = NULL
	vData = NULL          # Custom data associated with node
	nLevel = 0            # Depth level in tree

	func init cNewText
		cText = cNewText
		aChildren = []
		return self

	func addChild oNode
		oNode.oParent = ref(self)
		oNode.nLevel = nLevel + 1
		add(aChildren, ref(oNode))
		return oNode

	func addChildText cNewText
		oNode = new TUITreeNode(cNewText)
		oNode.oParent = ref(self)
		oNode.nLevel = nLevel + 1
		add(aChildren, ref(oNode))
		return oNode

	func hasChildren
		return len(aChildren) > 0

	func toggle
		lExpanded = not lExpanded

	func expand
		lExpanded = true

	func collapse
		lExpanded = false

	func expandAll
		lExpanded = true
		for nIndex = 1 to len(aChildren)
			aChildren[nIndex].expandAll()
		next

	func collapseAll
		lExpanded = false
		for nIndex = 1 to len(aChildren)
			aChildren[nIndex].collapseAll()
		next
