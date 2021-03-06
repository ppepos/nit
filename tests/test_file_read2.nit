# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

var f = new IFStream.open("test_file_read.nit")
print f.read_all

print "---"

f = new IFStream.open("test_file_read.nit")
print f.read_lines.join("\n")

print "---"

f = new IFStream.open("test_file_read.nit")
print f.each_line.to_a.join("\n")

print "---"

var p = "test_file_read.nit".to_path

print p.read_all
print "---"
print p.read_lines.join("\n")
print "---"
print p.each_line.to_a.join("\n")
