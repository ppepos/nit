module url

class Url

	var url: nullable String
	var scheme: nullable String
	var host: nullable String
	var port: nullable Int
	var path: nullable String
	var fragment: nullable String
	var query: nullable String

	private fun parse_url
	do
		var loc_url = url
		if loc_url == null then return
		if loc_url == "" then return

		# Scheme
		if loc_url.has("://") then
			scheme = loc_url.split_once_on("://")[0]
		else
			# Default to HTTP for now
			scheme = "http"
		end

	end
end

redef class String

	# Splits string on the first occurence of one of the delimiters
	# Returns the string split on that delimiter and the effective delimiter
	# If no delimiter is found, the string is returned along with an empty
	# string and a null delimiter
	#
	#     assert "foo/bar?baz".split_first("?", "/", "://") == ["foo", "bar?baz", "/"]
	#     assert "foo/bar?baz".split_first("1", "2", "3") == ["foo/bar?baz", "", null]
	fun split_first(delims: String...): Array[nullable String]
	do
		var min_idx: nullable Int = null
		var min_delim: nullable String = null

		for delim in delims do
			var match = self.search(delim)
			if match != null then
				var idx = match.from
				if min_idx == null or idx < min_idx then
					min_idx = idx
					min_delim = delim
				end
			end
		end

		if min_delim == null then return [self, "", null]

		var substrs = self.split_once_on(min_delim)
		return [substrs[0], substrs[1], min_delim]

	end

	# Returns a Url parsed from `self`
	#
	#     assert "http://nitlang.org/doc/stdlib?hai=true".to_url.path == "/doc/stdlib"
	#     assert "http://nitlang.org/doc/stdlib?hai=true".to_url.query == "hai=true"
	#     assert "http://nitlang.org/doc/stdlib?hai=true".to_url.scheme == "http"
	fun to_url: Url
	do
		var url = new Url(self)
		url.parse_url
		return url
	end
end

var u = "http://youtube.com"
var s = "foo/bar?baz"
print u.split_first("?", "/", "://")

