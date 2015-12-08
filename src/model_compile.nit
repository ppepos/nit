module model_compile

import frontend
import phase
import test_phase

redef class ToolContext
	var model_compile_phase: Phase = new ModelCompilePhase(self, null)
end

private class ModelCompilePhase
	super Phase
	redef fun process_mainmodule(mainmodule, given_mmodules)
	do 
		var modelbuilder = toolcontext.modelbuilder
		var model = modelbuilder.model
		var nmodule = modelbuilder.mmodule2node(mainmodule)
		
		var visitor = new ModelCompileVisitor(toolcontext, mainmodule)
		visitor.enter_visit(nmodule)
	end
end

private class ModelCompileVisitor
	super Visitor

	var toolcontext: ToolContext

	var mmodule: MModule

	redef fun visit(n)
	do
		n.accept_model_compile(self)
	end
end

###############################################################################

redef class ANode
	private fun accept_model_compile(v: ModelCompileVisitor)
	do
		visit_all(v)
	end
end

redef class Token
	private fun accept_model_compile_token(v: ModelCompileVisitor)
	do
	end
end

redef class AVardeclExpr
	redef fun accept_model_compile(v)
	do
		print "============="
		var my_var = variable
		print my_var or else "No var"
		print mtype or else "No type"
	end
end
