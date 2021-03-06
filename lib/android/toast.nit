# This file is part of NIT (http://www.nitlanguage.org).
#
# Copyright 2014 Alexis Laferrière <alexis.laf@xymus.net>
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

# Services to display a _toast_, a small popup on Android
module toast

import native_app_glue

in "Java" `{
	import android.widget.Toast;
`}

redef class App
	# Display a _toast_ with `message`, for longer if `is_long`
	fun toast(message: String, is_long: Bool)
	do
		var jstr = message.to_java_string
		native_toast(jstr, is_long)
		jstr.delete_local_ref
	end

	private fun native_toast(message: JavaString, is_long: Bool)
	import native_activity in "Java" `{
		final android.app.NativeActivity context = App_native_activity(recv);
		final CharSequence final_message = message;
		final int duration = is_long? Toast.LENGTH_LONG: Toast.LENGTH_SHORT;

		context.runOnUiThread(new Runnable() {
			@Override
			public void run()  {
				Toast toast = Toast.makeText(context, final_message, duration);
				toast.show();
			}
		});
	`}
end
