/* dfaserializer.vala
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

/** A DFA walker that knows how to dump them to serialized strings. */
public class Antlr4.Runtime.Dfa.DFASerializer : GLib.Object
{
	private DFA dfa { get; private set; }

	private Vocabulary vocabulary { get; private set; }

	/**
	 * @deprecated Use {@link #DFASerializer(DFA, Vocabulary)} instead.
	 */
	[Version (deprecated = true)]
	public DFASerializer.depr(DFA dfa, string[] token_names)
	{
		this(dfa, VocabularyImpl.from_token_names(token_names));
	}

	public DFASerializer(DFA dfa, Vocabulary vocabulary)
	{
		this.dfa = dfa;
		this.vocabulary = vocabulary;
	}

	public string? to_string()
	{
		if (dfa.s0 == null)
		    return null;
		StringBuilder buf = new StringBuilder();
		Gee.List<DFAState> states = dfa.states;
		foreach (DFAState s in states)
		{
			int n = 0;
			if (s.edges != null)
			    n = s.edges.length;
			for (var i = 0; i < n; i++)
			{
				DFAState t = s.edges[i];
				if (t != null && t.state_number != int.MAX)
				{
					buf.append(get_state_string(s));
					string label = get_edge_label(i);
					buf.append("-").append(label).append("->").append(get_state_string(t)).append_c('\n');
				}
			}
		}

		string output = buf.str;
		if (output.length == 0) return null;
		return output;
	}

	protected string get_edge_label(int i)
	{
		return vocabulary.get_display_name(i - 1);
	}


	protected string get_state_string(DFAState s)
	{
		int n = s.state_number;
		string base_state_str = "%ss%d%s".printf((s.is_accept_state ? ":" : ""), n, (s.requires_full_context ? "^" : ""));
		if (s.is_accept_state)
		{
            if (s.predicates != null) return "%s=>%s".printf(base_state_str, Util.array_to_string("[", "]", ", ", s.predicates.to_string_array()));
            else return "%s=>%s".printf(base_state_str, s.prediction.to_string());
		}
		else return base_state_str;
	}
}
