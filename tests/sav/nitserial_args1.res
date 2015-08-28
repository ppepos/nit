# This file is generated by nitserial
# Do not modify, but you can redef
module test_serialization_serial

import test_serialization
import serialization

redef class Deserializer
	redef fun deserialize_class(name)
	do
		# Module: test_serialization
		if name == "Array[String]" then return new Array[String].from_deserializer(self)
		if name == "Array[nullable Object]" then return new Array[nullable Object].from_deserializer(self)
		if name == "Array[Serializable]" then return new Array[Serializable].from_deserializer(self)
		if name == "Array[Object]" then return new Array[Object].from_deserializer(self)
		if name == "Array[Match]" then return new Array[Match].from_deserializer(self)
		return super
	end
end
