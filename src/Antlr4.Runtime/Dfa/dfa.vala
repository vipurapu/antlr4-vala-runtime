/* dfa.vala
 *
 * Copyright 2020 Valio Valtokari <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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
using Antrl4.Runtime.Error;
using Antrl4.Runtime.Misc;

public class Antrl4.Runtime.DFA : GLib.Object
{
   /**
    * A set of all DFA states. Use {@link Gee.Map} so we can get old state back
    * ({@link Gee.Set} only allows you to see if it's there).
    */
    public Gee.Map<DFAState, DFAState> states_map { get; default = new Gee.HashMap<DFAState, DFAState>(); }

    private DFAState s0;

    public int decision;

    /** From which ATN state did we create this DFA? */

    public DecisionState atn_start_state;

    /**
     * {@code true} if this DFA is for a precedence decision otherwise,
     * {@code false}. This is the backing field for {@link #is_precedence_dfa}.
     */
    private bool precedence_dfa { get; construct; }

    public DFA(DecisionState atn_start_state, int decision = 0)
    {
        this.atn_start_state = atn_start_state;
        this.decision = decision;

        var precedence_dfa = false;
        if (atn_start_state is StarLoopEntryState)
        {
            if (((StarLoopEntryState) atn_start_state).is_precedence_decision)
            {
                precedence_dfa = true;
                var precedence_state = new DFAState(new ATNConfigSet());
                precedence_state.edges = new DFAState[0];
                precedence_state.is_accept_state = false;
                precedence_state.requires_full_context = false;
                this.s0 = precedence_state;
            }
        }
        this.precedence_dfa = precedence_dfa;
    }

    /**
     * Gets whether this DFA is a precedence DFA. Precedence DFAs use a special
     * start state {@link #s0} which is not stored in {@link #states}. The
     * {@link DFAState#edges} array for this start state contains outgoing edges
     * supplying individual start states corresponding to specific precedence
     * values.
     *
     * @return {@code true} if this is a precedence DFA otherwise,
     * {@code false}.
     * @see Parser#getPrecedence()
     */
    public bool is_precedence_dfa
    {
        get
        {
            return precedence_dfa;
        }
    }

    /**
     * The start state for a specific precedence value.
     * @see #is_precedence_dfa()
     */
    public DFAState? precedence_start_state
    {
        get
        {
            if (!is_precedence_dfa)
                throw new StateError.ILLEGAL_STATE("Only precedence DFAs may contain a precedence start state.");

            // s0.edges is never null for a precedence DFA
            if (precedence < 0 || precedence >= s0.edges.length)
                return null;

            return s0.edges[precedence];
        }
        set
        {
            if (!is_precedence_dfa)
                throw new StateError.ILLEGAL_STATE("Only precedence DFAs may contain a precedence start state.");


            if (precedence < 0)
                return;

            // synchronization on s0 here is ok. when the DFA is turned into a
            // precedence DFA, s0 will be initialized once and not updated again
            lock (s0)
            {
                // s0.edges is never null for a precedence DFA
                if (precedence >= s0.edges.length)
                    s0.edges = Util.array_copy_of(s0.edges, precedence + 1);

                s0.edges[precedence] = (start_state);
            }
        }
    }
    /**
     * Return a list of all states in this DFA, ordered by state number.
     */
    public Gee.List<DFAState> states
    {
        get
        {
            var result = new Gee.ArrayList<DFAState>();
            result.add_all(states_map.keys);
            sort_dfa_states (ref result);

            return result;
        }
    }

    private static void sort_dfa_states(ref Gee.List<DFAState> states)
    {
        // A simple bubble sort algorithm.
        // <https://stackabuse.com/sorting-algorithms-in-java/>
        bool sorted = false;
        DFAState j;
        while (!sorted)
        {
            sorted = true;
            for (var i = 0; i < (states.size - 1); i++)
            {
                if (states[i].state_number > states[i + 1].state_number)
                {
                    j = states[i];
                    states[i] = states[i + 1];
                    states[i + 1] = j;
                    sorted = false;
                }
            }
        }
    }

    public string to_string(Vocabulary vocabulary = VocabularyImpl.EMPTY_VOCABULARY)
    {
        if (s0 == null)
            return "";

        var serializer = new DFASerializer(this, vocabulary);
        return serializer.to_string();
    }

    public string to_lexer_string()
    {
        if (s0 == null)
            return "";
        var serializer = new LexerDFASerializer(this);
        return serializer.to_string();
    }
}
