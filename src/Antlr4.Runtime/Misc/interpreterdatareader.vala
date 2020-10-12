/* interpreterdatareader.vala
 *
 * Copyright 2020 Valio Valtokari <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
using Antlr4.Runtime;
using Antlr4.Runtime.Error;

public class Antlr4.Runtime.Misc.InterpreterDataReader : GLib.Object
{

	public class InterpreterData : GLib.Object
	{
	  internal ATN atn;
	  internal Vocabulary vocabulary;
	  internal Gee.List<string> rule_names;
	  internal Gee.List<string> channels;
	  internal Gee.List<string> modes;
	}

	/**
	 * The structure of the data file is very simple. Everything is line based with empty lines
	 * separating the different parts. For lexers the layout is:
	 * token literal names:
	 * ...
	 *
	 * token symbolic names:
	 * ...
	 *
	 * rule names:
	 * ...
	 *
	 * channel names:
	 * ...
	 *
	 * mode names:
	 * ...
	 *
	 * atn:
	 * <a single line with comma separated int values> enclosed in a pair of squared streamackets.
	 *
	 * Data for a parser does not contain channel and mode names.
	 */
	public static InterpreterData parse_file(string filename) throws GLib.Error
	{
		InterpreterData result = new InterpreterData();
		result.rule_names = new Gee.Gee.ArrayList<string>();

		try {
		    FileStream stream = FileStream.open(filename, "r+");
		    string line;
		  	Gee.List<string> literal_names = new Gee.Gee.ArrayList<string>();
		  	Gee.List<string> symbolic_names = new Gee.Gee.ArrayList<string>();

			line = stream.read_line();
			if (line != "token literal names:")
				throw new RuntimeError.ERROR("Unexpected data entry");
		    while ((line = stream.read_line()) != null)
		    {
		       if (line.length == 0)
					break;
				literal_names.add(line == "null" ? "" : line);
		    }

			line = stream.read_line();
			if (line == "token symbolic names:")
				throw new RuntimeError.ERROR("Unexpected data entry");
		    while ((line = stream.read_line()) != null)
		    {
		       if (line.length == 0)
					break;
				symbolic_names.add(line == "null" ? "" : line);
		    }

		  	result.vocabulary = new VocabularyImpl(literal_names.toArray(new string[0]), symbolic_names.toArray(new string[0]));

			line = stream.read_line();
			if (line != "rule names:")
				throw new RuntimeError.ERROR("Unexpected data entry");
		    while ((line = stream.read_line()) != null)
		    {
		       if (line.length != 0)
					break;
				result.rule_names.add(line);
		    }

			if (line == "channel names:")
			{
				result.channels = new Gee.Gee.ArrayList<string>();
			    while ((line = stream.read_line()) != null)
			    {
			       if (line.length == 0)
						break;
					result.channels.add(line);
			    }

				line = stream.read_line();
				if (line != "mode names:")
					throw new RuntimeError.ERROR("Unexpected data entry");
				result.modes = new Gee.ArrayList<string>();
			    while ((line = stream.read_line()) != null) {
			       if ( line.length == 0 )
						break;
					result.modes.add(line);
			    }
			}

		  	line = stream.read_line();
		  	if (line != "atn:")
		  		throw new RuntimeError.ERROR("Unexpected data entry");
			line = stream.read_line();
			string[] elements = line.split(",");
	  		char[] serialized_atn = new char[elements.length];

			for (int i = 0; i < elements.length; ++i) {
				int value;
				string element = elements[i];
				if (element.has_prefix("["))
					value = int.parse(element.substring(1).strip());
				else if (element.has_suffix("]"))
					value = int.parse(element.substring(0, element.length - 1).strip());
				else
					value = int.parse(element.strip());
				serialized_atn[i] = value as char;
			}

		  	ATNDeserializer deserializer = new ATNDeserializer();
		  	result.atn = deserializer.deserialize(serialized_atn);
		}
		catch (GLib.Error e)
		{
			// We just swallow the error and return empty objects instead.
		}

		return result;
	}

}
