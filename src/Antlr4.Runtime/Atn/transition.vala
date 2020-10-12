/* transition.vala
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

/** An ATN transition between any two ATN states.  Subclasses define
 *  atom, set, epsilon, action, predicate, rule transitions.
 *
 *  <p>This is a one way link.  It emanates from a state (usually via a list of
 *  transitions) and has a target state.</p>
 *
 *  <p>Since we never have to change the ATN transitions once we construct it,
 *  we can fix these transitions as specific classes. The DFA transitions
 *  on the other hand need to update the labels as it adds transitions to
 *  the states. We'll use the term Edge for the DFA to distinguish them from
 *  ATN transitions.</p>
 */
using Antlr4.Runtime.Misc;

public abstract class Antlr4.Runtime.Atn.Transition : GLib.Object
{
	// constants for serialization
	public const uint EPSILON		    = 1;
	public const uint RANGE			    = 2;
	public const uint RULE			    = 3;
	public const uint PREDICATE		    = 4; // e.g., {isType(input.LT(1))}?
	public const uint ATOM			    = 5;
	public const uint ACTION		    = 6;
	public const uint SET			    = 7; // ~(A|B) or ~atom, wildcard, which convert to next 2
	public const uint NOT_SET		    = 8;
	public const uint WILDCARD		    = 9;
	public const uint PRECEDENCE	    = 10;


	public Gee.List<string> serialization_names { get; default =
		new Gee.ArrayList<string>.wrap({
			"INVALID",
			"EPSILON",
			"RANGE",
			"RULE",
			"PREDICATE",
			"ATOM",
			"ACTION",
			"SET",
			"NOT_SET",
			"WILDCARD",
			"PRECEDENCE"
		});
    }

	public Gee.Map<Type, uint> serialization_types { get; default =
		new Gee.HashMap<Type, uint>();
	}

	construct
	{
		serialization_types[typeof(EpsilonTransition)] = EPSILON;
		serialization_types[typeof(RangeTransition)] = RANGE;
		serialization_types[typeof(RuleTransition)] = RULE;
		serialization_types[typeof(PredicateTransition)] = PREDICATE;
		serialization_types[typeof(AtomTransition)] = ATOM;
		serialization_types[typeof(ActionTransition)] = ACTION;
		serialization_types[typeof(SetTransition)] = SET;
		serialization_types[typeof(NotSetTransition)] = NOT_SET;
		serialization_types[typeof(WildcardTransition)] = WILDCARD;
		serialization_types[typeof(PrecedencePredicateTransition)] = PRECEDENCE;
	}

	/** The target of this transition. */

	public ATNState target;

	protected Transition(ATNState target)
	{
		this.target = target;
	}

	public abstract int serialization_type { get; protected set; }

	/**
	 * Determines if the transition is an "epsilon" transition.
	 *
	 * <p>The default implementation returns {@code false}.</p>
	 *
	 * @return {@code true} if traversing this transition in the ATN does not
	 * consume an input symbol; otherwise, {@code false} if traversing this
	 * transition consumes (matches) an input symbol.
	 */
	public bool is_epsilon
	{
	    get
	    {
	        return false;
	    }
	}


	public IntervalSet? label
	{
	    get
	    {
	        return null;
	    }
	}

	public abstract bool matches(int symbol, int min_vocab_symbol, int max_vocab_symbol);
}
