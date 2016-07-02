module butter

import butter_parser
import butter_lexer

class Butter
	super Visitor

	var out = ""

	redef fun visit(n) do n.accept_butter(self)
end

redef class Node
	fun accept_butter(v: Butter) do
		# print self.class_name
		visit_children(v)
	end
end

redef class Ntext
	redef fun accept_butter(v) do v.out += "out += \"\"\"{self.text}\"\"\"\n"
end

redef class Nvar_tag
	redef fun accept_butter(v) do

		var var_name = self.text
		var_name = var_name.remove_all("(\\\{\\\{\\\s*)|(\\\s*}})".to_re)

		v.out += "out += \"\\\{\\\{\\\{ \" \n"
		v.out += "out += \"{var_name}\" \n"
		v.out += "out += \" }}}\"\n"
	end
end

redef class Parser_butter

	fun new_lexer(text: String): Lexer_butter do return new Lexer_butter(text)

	# How to get a new parser
	fun new_parser: Parser is abstract

	fun main(filepath: String): Node do

		var text
		var f = new FileReader.open(filepath)
		text = f.read_all
		f.close

		return work(text)
	end

	fun work(text: String): Node do
		var l = new_lexer(text)
		var tokens = l.lex

		self.tokens.add_all(tokens)

		var n = self.parse

		if n isa NError then
			print "Syntax error: {n.message}"
		end

		return n
	end
end

fun build_header(template_name: String): String do
	var out = """
class {{{template_name}}}
	fun render: String do
		var out = ""
"""
	return out
end

fun build_footer: String do
	var out = """
		return out
	end
end
var c = new Test
print c.render
"""
	return out
end

if args.is_empty then
	print "usage : butter <template_file1> [template_file2 ...]"
	exit 0
end

for arg in args do

	var out_dir = arg.dirname
	var out_name = arg.basename(".html") + ".nit"
	var out_path = out_dir.join_path(out_name)
	var out_file = new FileWriter.open(out_path)

	var butter_parser = new Parser_butter
	var node = butter_parser.main(arg)
	var visitor = new Butter
	visitor.enter_visit(node)

	out_file.write(build_header(arg.basename(".html").capitalized))
	out_file.write(visitor.out)
	out_file.write(build_footer)
end
