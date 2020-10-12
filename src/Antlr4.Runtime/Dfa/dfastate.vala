/* dfastate.vala
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

/**
 * A DFA state represents a set of possible ATN configurations.
 * As Aho, Sethi, Ullman p. 117 says "The DFA uses its state
 * to keep track of all possible states the ATN can be in after
 * reading each input symbol.  That is to say, after reading
 * input a1a2..an, the DFA is in a state that represents the
 * subset T of the states of the ATN that are reachable from the
 * ATN's start state along some path labeled a1a2..an."
 * In conventional NFA&rarr;DFA conversion, therefore, the subset T
 * would be a bitset representing the set of states the
 * ATN could be in.  We need to track the alt predicted by each
 * state as well, however.  More importantly, we need to maintain
 * a stack of states, tracking the closure operations as they
 * jump from rule to rule, emulating rule invocations (method calls).
 * I have to add a stack to simulate the proper lookahead sequences for
 * the underlying LL grammar from which the ATN was derived.
 *
 * <p>I use a set of ATNConfig objects not simple states.  An ATNConfig
 * is both a state (ala normal conversion) and a RuleContext describing
 * the chain of rules (if any) followed to arrive at that state.</p>
 *
 * <p>A DFA state may have multiple references to a particular state,
 * but with different ATN contexts (with same or different alts)
 * meaning that state was reached via a different set of rule invocations.</p>
 */
public class Antlr4.Runtime.Dfa.DFAState : GLib.Object, Hashable
{
	public int state_number;

	public ATNConfigSet? configs = new ATNConfigSet();

	/**
	 * {@code edges[symbol]} points to target of symbol. Shift up by 1 so (-1)
	 * {@link Token#EOF} maps to {@code edges[0]}.
	 */

	public DFAState[] edges;

	public bool is_accept_state = false;

	/** if accept state, what ttype do we match or alt do we predict?
	 * This is set to {@link ATN#INVALID_ALT_NUMBER} when {@link #predicates}{@code !=null} or
	 * {@link #requires_full_context}.
	 */
	public int prediction;

	public LexerActionExecutor lexer_action_executor;

	/**
	 * Indicates that this state was created during SLL prediction that
	 * discovered a conflict between the configurations in the state. Future
	 * {@link ParserATNSimulator#execATN} invocations immediately jumped doing
	 * full context prediction if this field is true.
	 */
	public bool requires_full_context;

	/** During SLL parsing, this is a list of predicates associated with the
	 * ATN configurations of the DFA state. When we have predicates,
	 * {@link #requires_full_context} is {@code false} since full context prediction evaluates predicates
	 * on-the-fly. If this is not null, then {@link #prediction} is
	 * {@link ATN#INVALID_ALT_NUMBER}.
	 *
	 * <p>We only use these for non-{@link #requires_full_context} but conflicting states. That
	 * means we know from the context (it's $ or we don't dip into outer
	 * context) that it's an ambiguity not a conflict.</p>
	 *
	 * <p>This list is computed by {@link ParserATNSimulator#predicateDFAState}.</p>
	 */

	public PredPrediction[]? predicates;

	/** Map a predicate to a predicted alternative. */
	public class PredPrediction : GLib.Object
	{
		public SemanticContext pred; // never null; at least SemanticContext.NONE
		public int alt;
		public PredPrediction(SemanticContext pred, int alt)
		{
			this.alt = alt;
			this.pred = pred;
		}

		public string to_string()
		{
			return "(%s, %d)".printf(pred.to_string(), alt);
		}
	}

	public DFAState(int state_number = -1) { this.state_number = state_number; }

	public DFAState.configset(ATNConfigSet? configs) { this.configs = configs; }

	/**
	 * Get the set of all alts mentioned by all ATN configurations in this
	 * DFA state.
	 */
	public Gee.Set<int?>? alt_set
	{
	    get
	    {
		    var alts = new Gee.HashSet<int?>();
		    if (configs != null)
		    {
			    foreach (ATNConfig c in configs)
			    	alts.add(c.alt);
		    }
		    if (alts.is_empty) return null;
		    return alts;
	    }
	}

	public override uint64 hash_code()
	{
		var hash = MurmurHash.initialize(7);
		hash = MurmurHash.update(hash, configs.hash_code());
		hash = MurmurHash.finish(hash, 1);
		return hash;
	}

	/**
	 * Two {@link DFAState} instances are equal if their ATN configuration sets
	 * are the same. This method is used to see if a state already exists.
	 *
	 * <p>Because the number of alternatives and number of ATN configurations are
	 * finite, there is a finite number of DFA states that can be processed.
	 * This is necessary to show that the algorithm terminates.</p>
	 *
	 * <p>Cannot test the DFA state numbers here because in
	 * {@link ParserATNSimulator#addDFAState} we need to know if any other state
	 * exists that has this exact set of ATN configurations. The
	 * {@link #state_number} is irrelevant.</p>
	 */
	public bool equals(DFAState o)
	{
		// compare set of ATN configurations in this set with other
		if (this == o) return true;

		// TODO (sam): what to do when configs==null?
		// Maybe like this?
		bool same_set = (this.configs == null) ? false : this.configs.equals(other.configs);
		//bool same_set = this.configs.equals(other.configs);
		return same_set;
	}

	public string to_string()
	{
        StringBuilder buf = new StringBuilder();
        buf.append(state_number.to_string()).append(":").append(configs.to_string());
        if (is_accept_state)
        {
            buf.append("=>");
            if (predicates != null)
                buf.append(Util.array_to_string("[", "]", ", ", predicates.to_string_array()));
            else buf.append(prediction.to_string());
        }
		return buf.str;
	}
}
