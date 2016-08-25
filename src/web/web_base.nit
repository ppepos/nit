# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Base classes used by `nitweb`.
module web_base

import model::model_views
import model::model_json
import doc_down
import popcorn
import popcorn::pop_config
import popcorn::pop_repos

# Nitweb config file.
class NitwebConfig
	super AppConfig

	redef var default_db_name = "nitweb"

	# Model to use.
	var model: Model

	# MModule used to flatten model.
	var mainmodule: MModule

	# Modelbuilder used to access sources.
	var modelbuilder: ModelBuilder
end

# Specific handler for the nitweb API.
abstract class APIHandler
	super Handler

	# App config.
	var config: NitwebConfig

	# Find the MEntity ` with `full_name`.
	fun find_mentity(model: ModelView, full_name: nullable String): nullable MEntity do
		if full_name == null then return null
		return model.mentity_by_full_name(full_name.from_percent_encoding)
	end

	# The JSON API does not filter anything by default.
	#
	# So we can cache the model view.
	var view: ModelView is lazy do
		var view = new ModelView(config.model)
		view.min_visibility = private_visibility
		view.include_fictive = true
		view.include_empty_doc = true
		view.include_attribute = true
		view.include_test_suite = true
		return view
	end

	# Try to load the mentity from uri with `/:id`.
	#
	# Send 400 if `:id` is null.
	# Send 404 if no entity is found.
	# Return null in both cases.
	fun mentity_from_uri(req: HttpRequest, res: HttpResponse): nullable MEntity do
		var id = req.param("id")
		if id == null then
			res.api_error(400, "Expected mentity full name")
			return null
		end
		var mentity = find_mentity(view, id)
		if mentity == null then
			res.api_error(404, "MEntity `{id}` not found")
		end
		return mentity
	end
end

# A Rooter dedicated to APIHandlers.
class APIRouter
	super Router

	# App config
	var config: NitwebConfig
end

redef class HttpResponse

	# Return an HTTP error response with `status`
	#
	# Like the rest of the API, errors are formated as JSON:
	# ~~~json
	# { "status": 404, "message": "Not found" }
	# ~~~
	fun api_error(status: Int, message: String) do
		json(new APIError(status, message), status)
	end
end

# An error returned by the API.
#
# Can be serialized to json.
class APIError
	super Jsonable

	# Reponse status
	var status: Int

	# Response error message
	var message: String

	# Json Object for this error
	var json: JsonObject is lazy do
		var obj = new JsonObject
		obj["status"] = status
		obj["message"] = message
		return obj
	end

	redef fun to_json do return json.to_json
end

redef class MEntity

	# URL to `self` within the web interface.
	fun web_url: String do return "/doc/" / full_name

	# URL to `self` within the JSON api.
	fun api_url: String do return "/api/entity/" / full_name

	redef fun json do
		var obj = super
		obj["web_url"] = web_url
		obj["api_url"] = api_url
		return obj
	end

	# Get the full json repesentation of `self` with MEntityRefs resolved.
	fun api_json(handler: APIHandler): JsonObject do return full_json
end

redef class MEntityRef
	redef fun json do
		var obj = super
		obj["web_url"] = mentity.web_url
		obj["api_url"] = mentity.api_url
		obj["name"] = mentity.name
		obj["mdoc"] = mentity.mdoc_or_fallback
		obj["visibility"] = mentity.visibility
		var modifiers = new JsonArray
		for modifier in mentity.collect_modifiers do
			modifiers.add modifier
		end
		obj["modifiers"] = modifiers
		var mentity = self.mentity
		if mentity isa MMethod then
			obj["msignature"] = mentity.intro.msignature
		else if mentity isa MMethodDef then
			obj["msignature"] = mentity.msignature
		else if mentity isa MVirtualTypeProp then
			obj["bound"] = to_mentity_ref(mentity.intro.bound)
		else if mentity isa MVirtualTypeDef then
			obj["bound"] = to_mentity_ref(mentity.bound)
		end
		return obj
	end

	redef fun full_json do
		var obj = super
		obj["location"] = mentity.location
		return obj
	end
end

redef class MDoc

	# Add doc down processing
	redef fun json do
		var obj = new JsonObject
		obj["html_synopsis"] = html_synopsis.write_to_string
		obj["html_documentation"] = html_documentation.write_to_string
		return obj
	end
end

redef class MClassType
	redef var web_url = mclass.web_url is lazy
end

redef class MNullableType
	redef var web_url = mtype.web_url is lazy
end

redef class MParameterType
	redef var web_url = mclass.web_url is lazy
end

redef class MVirtualType
	redef var web_url = mproperty.web_url is lazy
end

redef class POSetElement[E]
	super Jsonable

	# Return JSON representation of `self`.
	fun json: JsonObject do
		assert self isa POSetElement[MEntity]
		var obj = new JsonObject
		obj["greaters"] = to_mentity_refs(greaters)
		obj["direct_greaters"] = to_mentity_refs(direct_greaters)
		obj["direct_smallers"] = to_mentity_refs(direct_smallers)
		obj["smallers"] = to_mentity_refs(smallers)
		return obj
	end

	redef fun to_json do return json.to_json
end
