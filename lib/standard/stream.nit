# This file is part of NIT ( http://www.nitlanguage.org ).
#
# This file is free software, which comes along with NIT. This software is
# distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. You can modify it is you want, provided this header
# is kept unaltered, and a notification of the changes is added.
# You are allowed to redistribute it and sell it, alone or is a part of
# another product.

# Input and output streams of characters
module stream

intrude import ropes
import error

in "C" `{
	#include <unistd.h>
	#include <string.h>
	#include <signal.h>
`}

# Any kind of error that could be produced by an operation on Streams
class IOError
	super Error
end

# Abstract stream class
abstract class IOS
	# Error produced by the file stream
	#
	#     var ifs = new IFStream.open("donotmakethisfile.binx")
	#     ifs.read_all
	#     ifs.close
	#     assert ifs.last_error != null
	var last_error: nullable IOError = null

	# close the stream
	fun close is abstract
end

# Abstract input streams
abstract class IStream
	super IOS
	# Read a character. Return its ASCII value, -1 on EOF or timeout
	fun read_char: Int is abstract

	# Read at most i bytes
	fun read(i: Int): String
	do
		if last_error != null then return ""
		var s = new FlatBuffer.with_capacity(i)
		while i > 0 and not eof do
			var c = read_char
			if c >= 0 then
				s.add(c.ascii)
				i -= 1
			end
		end
		return s.to_s
	end

	# Read a string until the end of the line.
	#
	# The line terminator '\n' and '\r\n', if any, is removed in each line.
	#
	# ~~~
	# var txt = "Hello\n\nWorld\n"
	# var i = new StringIStream(txt)
	# assert i.read_line == "Hello"
	# assert i.read_line == ""
	# assert i.read_line == "World"
	# assert i.eof
	# ~~~
	#
	# Only LINE FEED (`\n`), CARRIAGE RETURN & LINE FEED (`\r\n`), and
	# the end or file (EOF) is considered to delimit the end of lines.
	# CARRIAGE RETURN (`\r`) alone is not used for the end of line.
	#
	# ~~~
	# var txt2 = "Hello\r\n\n\rWorld"
	# var i2 = new StringIStream(txt2)
	# assert i2.read_line == "Hello"
	# assert i2.read_line == ""
	# assert i2.read_line == "\rWorld"
	# assert i2.eof
	# ~~~
	#
	# NOTE: Use `append_line_to` if the line terminator needs to be preserved.
	fun read_line: String
	do
		if last_error != null then return ""
		if eof then return ""
		var s = new FlatBuffer
		append_line_to(s)
		return s.to_s.chomp
	end

	# Read all the lines until the eof.
	#
	# The line terminator '\n' and `\r\n` is removed in each line,
	#
	# ~~~
	# var txt = "Hello\n\nWorld\n"
	# var i = new StringIStream(txt)
	# assert i.read_lines == ["Hello", "", "World"]
	# ~~~
	#
	# This method is more efficient that splitting
	# the result of `read_all`.
	#
	# NOTE: SEE `read_line` for details.
	fun read_lines: Array[String]
	do
		var res = new Array[String]
		while not eof do
			res.add read_line
		end
		return res
	end

	# Return an iterator that read each line.
	#
	# The line terminator '\n' and `\r\n` is removed in each line,
	# The line are read with `read_line`. See this method for details.
	#
	# ~~~
	# var txt = "Hello\n\nWorld\n"
	# var i = new StringIStream(txt)
	# assert i.each_line.to_a == ["Hello", "", "World"]
	# ~~~
	#
	# Unlike `read_lines` that read all lines at the call, `each_line` is lazy.
	# Therefore, the stream should no be closed until the end of the stream.
	#
	# ~~~
	# i = new StringIStream(txt)
	# var el = i.each_line
	#
	# assert el.item == "Hello"
	# el.next
	# assert el.item == ""
	# el.next
	#
	# i.close
	#
	# assert not el.is_ok
	# # closed before "world" is read
	# ~~~
	fun each_line: LineIterator do return new LineIterator(self)

	# Read all the stream until the eof.
	#
	# The content of the file is returned verbatim.
	#
	# ~~~
	# var txt = "Hello\n\nWorld\n"
	# var i = new StringIStream(txt)
	# assert i.read_all == txt
	# ~~~
	fun read_all: String
	do
		if last_error != null then return ""
		var s = new FlatBuffer
		while not eof do
			var c = read_char
			if c >= 0 then s.add(c.ascii)
		end
		return s.to_s
	end

	# Read a string until the end of the line and append it to `s`.
	#
	# Unlike `read_line` and other related methods,
	# the line terminator '\n', if any, is preserved in each line.
	# Use the method `Text::chomp` to safely remove it.
	#
	# ~~~
	# var txt = "Hello\n\nWorld\n"
	# var i = new StringIStream(txt)
	# var b = new FlatBuffer
	# i.append_line_to(b)
	# assert b == "Hello\n"
	# i.append_line_to(b)
	# assert b == "Hello\n\n"
	# i.append_line_to(b)
	# assert b == txt
	# assert i.eof
	# ~~~
	#
	# If `\n` is not present at the end of the result, it means that
	# a non-eol terminated last line was returned.
	#
	# ~~~
	# var i2 = new StringIStream("hello")
	# assert not i2.eof
	# var b2 = new FlatBuffer
	# i2.append_line_to(b2)
	# assert b2 == "hello"
	# assert i2.eof
	# ~~~
	#
	# NOTE: The single character LINE FEED (`\n`) delimits the end of lines.
	# Therefore CARRIAGE RETURN & LINE FEED (`\r\n`) is also recognized.
	fun append_line_to(s: Buffer)
	do
		if last_error != null then return
		loop
			var x = read_char
			if x == -1 then
				if eof then return
			else
				var c = x.ascii
				s.chars.push(c)
				if c == '\n' then return
			end
		end
	end

	# Is there something to read.
	# This function returns 'false' if there is something to read.
	fun eof: Bool is abstract
end

# Iterator returned by `IStream::each_line`.
# See the aforementioned method for details.
class LineIterator
	super Iterator[String]

	# The original stream
	var stream: IStream

	redef fun is_ok
	do
		var res = not stream.eof
		if not res and close_on_finish then stream.close
		return res
	end

	redef fun item
	do
		var line = self.line
		if line == null then
			line = stream.read_line
		end
		self.line = line
		return line
	end

	# The last line read (cache)
	private var line: nullable String = null

	redef fun next
	do
		# force the read
		if line == null then item
		# drop the line
		line = null
	end

	# Close the stream when the stream is at the EOF.
	#
	# Default is false.
	var close_on_finish = false is writable

	redef fun finish
	do
		if close_on_finish then stream.close
	end
end

# IStream capable of declaring if readable without blocking
abstract class PollableIStream
	super IStream

	# Is there something to read? (without blocking)
	fun poll_in: Bool is abstract

end

# Abstract output stream
abstract class OStream
	super IOS
	# write a string
	fun write(s: Text) is abstract

	# Can the stream be used to write
	fun is_writable: Bool is abstract
end

# Things that can be efficienlty writen to a OStream
#
# The point of this interface it to allow is instance to be efficenty
# writen into a OStream without having to allocate a big String object
#
# ready-to-save documents usually provide this interface.
interface Streamable
	# Write itself to a `stream`
	# The specific logic it let to the concrete subclasses
	fun write_to(stream: OStream) is abstract

	# Like `write_to` but return a new String (may be quite large)
	#
	# This funtionnality is anectodical, since the point
	# of streamable object to to be efficienlty written to a
	# stream without having to allocate and concatenate strings
	fun write_to_string: String
	do
		var stream = new StringOStream
		write_to(stream)
		return stream.to_s
	end
end

redef class Text
	super Streamable
	redef fun write_to(stream) do stream.write(self)
end

# Input streams with a buffer
abstract class BufferedIStream
	super IStream
	redef fun read_char
	do
		if last_error != null then return -1
		if eof then
			last_error = new IOError("Stream has reached eof")
			return -1
		end
		var c = _buffer.chars[_buffer_pos]
		_buffer_pos += 1
		return c.ascii
	end

	redef fun read(i)
	do
		if last_error != null then return ""
		if _buffer.length == _buffer_pos then
			if not eof then
				return read(i)
			end
			return ""
		end
		if _buffer_pos + i >= _buffer.length then
			var from = _buffer_pos
			_buffer_pos = _buffer.length
			return _buffer.substring_from(from).to_s
		end
		_buffer_pos += i
		return _buffer.substring(_buffer_pos - i, i).to_s
	end

	redef fun read_all
	do
		if last_error != null then return ""
		var s = new FlatBuffer
		while not eof do
			var j = _buffer_pos
			var k = _buffer.length
			while j < k do
				s.add(_buffer[j])
				j += 1
			end
			_buffer_pos = j
			fill_buffer
		end
		return s.to_s
	end

	redef fun append_line_to(s)
	do
		loop
			# First phase: look for a '\n'
			var i = _buffer_pos
			while i < _buffer.length and _buffer.chars[i] != '\n' do i += 1

			var eol
			if i < _buffer.length then
				assert _buffer.chars[i] == '\n'
				i += 1
				eol = true
			else
				eol = false
			end

			# if there is something to append
			if i > _buffer_pos then
				# Enlarge the string (if needed)
				s.enlarge(s.length + i - _buffer_pos)

				# Copy from the buffer to the string
				var j = _buffer_pos
				while j < i do
					s.add(_buffer.chars[j])
					j += 1
				end
				_buffer_pos = i
			else
				assert end_reached
				return
			end

			if eol then
				# so \n is found
				return
			else
				# so \n is not found
				if end_reached then return
				fill_buffer
			end
		end
	end

	redef fun eof
	do
		if _buffer_pos < _buffer.length then return false
		if end_reached then return true
		fill_buffer
		return _buffer_pos >= _buffer.length and end_reached
	end

	# The buffer
	private var buffer: nullable FlatBuffer = null

	# The current position in the buffer
	private var buffer_pos: Int = 0

	# Fill the buffer
	protected fun fill_buffer is abstract

	# Is the last fill_buffer reach the end
	protected fun end_reached: Bool is abstract

	# Allocate a `_buffer` for a given `capacity`.
	protected fun prepare_buffer(capacity: Int)
	do
		_buffer = new FlatBuffer.with_capacity(capacity)
		_buffer_pos = 0 # need to read
	end
end

# An Input/Output Stream
abstract class IOStream
	super IStream
	super OStream
end

# Stream to a String.
#
# Mainly used for compatibility with OStream type and tests.
class StringOStream
	super OStream

	private var content = new Array[String]
	redef fun to_s do return content.to_s
	redef fun is_writable do return not closed
	redef fun write(str)
	do
		assert not closed
		content.add(str.to_s)
	end

	# Is the stream closed?
	protected var closed = false

	redef fun close do closed = true
end

# Stream from a String.
#
# Mainly used for compatibility with IStream type and tests.
class StringIStream
	super IStream

	# The string to read from.
	var source: String

	# The current position in the string.
	private var cursor: Int = 0

	redef fun read_char do
		if cursor < source.length then
			var c = source[cursor].ascii

			cursor += 1
			return c
		else
			return -1
		end
	end

	redef fun close do
		source = ""
	end

	redef fun eof do return cursor >= source.length
end
