class Test
	fun render: String do
		var out = ""
out += """<ul>
	"""
out += """
	<li><a href=""""
out += "\{\{\{ " 
out += "user" 
out += " }}}"
out += """">"""
out += "\{\{\{ " 
out += "user" 
out += " }}}"
out += """</a></li>
	"""
out += """
</ul>
"""
		return out
	end
end
var c = new Test
print c.render
