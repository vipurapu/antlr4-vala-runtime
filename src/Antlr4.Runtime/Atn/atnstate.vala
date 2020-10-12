/* atnstate.vala
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
using Antlr4.Runtime.Misc;

public abstract class Antlr4.Runtime.Atn.ATNState : GLib.Object, Hashable
{
	public const int INITIAL_NUM_TRANSITIONS = 4;

	// constants for serialization
	public const int INVALID_TYPE = 0;
	public const int BASIC = 1;
	public const int RULE_START = 2;
	public const int BLOCK_START = 3;
	public const int PLUS_BLOCK_START = 4;
	public const int STAR_BLOCK_START = 5;
	public const int TOKEN_START = 6;
	public const int RULE_STOP = 7;
	public const int BLOCK_END = 8;
	public const int STAR_LOOP_BACK = 9;
	public const int STAR_LOOP_ENTRY = 10;
	public const int PLUS_LOOP_BACK = 11;
	public const int LOOP_END = 12;

	public Gee.List<string> serialization_names { get; default =
		new Gee.ArrayList<string>.wrap({
			"INVALID",
			"BASIC",
			"RULE_START",
			"BLOCK_START",
			"PLUS_BLOCK_START",
			"STAR_BLOCK_START",
			"TOKEN_START",
			"RULE_STOP",
			"BLOCK_END",
			"STAR_LOOP_BACK",
			"STAR_LOOP_ENTRY",
			"PLUS_LOOP_BACK",
			"LOOP_END"
		});
	}

	public const int INVALID_STATE_NUMBER = -1;

    /** Which ATN are we in? */
   	public ATN atn = null;

	public int state_number = INVALID_STATE_NUMBER;

	public int rule_index; // at runtime, we don't have Rule objects

	public bool epsilon_only_transitions = false;

	/** Track the transitions emanating from this ATN state. */
	public Gee.List<Transition> transitions
	{
	    get;
	    default = new Gee.ArrayList<Transition>(new Transition[INITIAL_NUM_TRANSITIONS]);
	}

	/** Used to cache lookahead during parsing, not used during construction */
    public IntervalSet next_token_within_rule;


	public uint64 hash_code()
	{
	    return state_number;
	}


	public bool equals(ATNState o)
	{
		// are these states same object?
		return state_number == o.state_number;
	}

	public bool is_non_greedy_exit_state()
	{
		return false;
	}


	public string to_string()
	{
		return state_number.to_string();
	}

	public int get_number_of_transitions()
	{
		return transitions.size;
	}

	public void add_transition(Transition e, int index = transitions.size)
	{
		if (transitions.is_empty())
			epsilon_only_transitions = e.isEpsilon();

		else if (epsilon_only_transitions != e.is_epsilon())
		{
			stderr.printf("ATN state %d has both epsilon and non-epsilon transitions.\n", state_number);
			epsilon_only_transitions = false;
		}

		bool already_present = false;
		foreach (Transition t in transitions)
		{
			if (t.target.state_number == e.target.state_number )
			{
				if (t.label() != null && e.label() != null && t.label() == e.label())
				{
					already_present = true;
					break;
				}
				else if (t.is_epsilon() && e.is_epsilon())
				{
					already_present = true;
					break;
				}
			}
		}
		if (!already_present)
			transitions.insert(index, e);
	}

	public Transition transition(int i)
	{
	    return transitions.get(i);
	}

	public void set_transition(int i, Transition e)
	{
		transitions[i] = e;
	}

	public Transition remove_transition(int index)
	{
		return transitions.remove_at(index);
	}

	public abstract int get_state_type();

	public sealed bool only_has_epsilon_transitions()
	{
		return epsilon_only_transitions;
	}

	public void set_rule_index(int rule_index)
	{
	    this.rule_index = rule_index;
	}
}
