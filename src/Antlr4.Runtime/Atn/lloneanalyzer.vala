/* lloneanalyzer.vala
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

public class Antlr4.Runtime.Atn.LL1Analyzer : GLib.Object
{
	/**
	 * Special value added to the lookahead sets to indicate that we hit
	 * a predicate during analysis if {{{seeThruPreds==false}}}.
	 */
	public const int HIT_PRED = Token.INVALID_TYPE;

	public ATN atn { get; construct; }

	public LL1Analyzer(ATN _atn)
	{
	    Object(atn: _atn);
	}

	/**
	 * Calculates the SLL(1) expected lookahead set for each outgoing transition
	 * of an {@link ATNState}. The returned array has one element for each
	 * outgoing transition in {{{s}}}. If the closure from transition
	 * //i// leads to a semantic predicate before matching a symbol, the
	 * element at index //i// of the result will be {{{null}}}.
	 *
	 * @param s the ATN state
	 * @return the expected symbols for each outgoing transition of {{{s}}}.
	 */
	public IntervalSet[]? get_decision_lookahead(ATNState s)
	{
		if (s == null)
			return null;

        var transitions = s.get_number_of_transitions();
		IntervalSet[] look = new IntervalSet[transitions];
		for (int alt = 0; alt < transitions; alt++)
		{
			look[alt] = new IntervalSet();
			Gee.Set<ATNConfig> look_busy = new HashSet<ATNConfig>();
			bool see_thru_preds = false; // fail to get lookahead upon pred
			_LOOK(s.transition(alt).target, null, PredictionContext.EMPTY,
				  look[alt], look_busy, new BitSet(), seeThruPreds, false);
			// Wipe out lookahead for this alternative if we found nothing
			// or we had a predicate when we !seeThruPreds
			if (look[alt].size()==0 || look[alt].contains(HIT_PRED) ) {
				look[alt] = null;
			}
		}
		return look;
	}

	/**
	 * Compute set of tokens that can follow {{{s}}} in the ATN in the
	 * specified {{{ctx}}}.
	 *
	 * If {{{ctx}}} is {{{null}}} and the end of the rule containing
	 * {{{s}}} is reached, {@link Token#EPSILON} is added to the result set.
	 * If {{{ctx}}} is not {{{null}}} and the end of the outermost rule is
	 * reached, {@link Token#EOF} is added to the result set.
	 *
	 * @param s the ATN state
	 * @param stop_state the ATN state to stop at. This can be a
	 * {@link BlockEndState} to detect epsilon paths through a closure.
	 * @param ctx the complete parser context, or {{{null}}} if the context
	 * should be ignored
	 *
	 * @return The set of tokens that can follow {{{s}}} in the ATN in the
	 * specified {{{ctx}}}.
	 */

   	public IntervalSet LOOK(ATNState s, RuleContext ctx, ATNState? stop_state = null)
   	{
   		IntervalSet r = new IntervalSet();
		bool see_thru_preds = true; // ignore preds; get all lookahead
		PredictionContext look_context = ctx != null ? PredictionContext.fromRuleContext(s.atn, ctx) : null;
   		_LOOK(s, stop_state, look_context,
			  r, new Gee.HashSet<ATNConfig>(), new BitSet(), seeThruPreds, true);
   		return r;
   	}

	/**
	 * Compute set of tokens that can follow {{{s}}} in the ATN in the
	 * specified {{{ctx}}}.
	 *
	 * If {{{ctx}}} is {{{null}}} and {{{stop_state}}} or the end of the
	 * rule containing {{{s}}} is reached, {@link Token#EPSILON} is added to
	 * the result set. If {{{ctx}}} is not {{{null}}} and {{{addEOF}}} is
	 * {{{true}}} and {{{stop_state}}} or the end of the outermost rule is
	 * reached, {@link Token#EOF} is added to the result set.
	 *
	 * @param s the ATN state.
	 * @param stop_state the ATN state to stop at. This can be a
	 * {@link BlockEndState} to detect epsilon paths through a closure.
	 * @param ctx The outer context, or {{{null}}} if the outer context should
	 * not be used.
	 * @param look The result lookahead set.
	 * @param look_busy A set used for preventing epsilon closures in the ATN
	 * from causing a stack overflow. Outside code should pass
	 * {@code new HashSet<ATNConfig>} for this argument.
	 * @param calledRuleStack A set used for preventing left recursion in the
	 * ATN from causing a stack overflow. Outside code should pass
	 * {@code new BitSet()} for this argument.
	 * @param seeThruPreds {{{true}}} to true semantic predicates as
	 * implicitly {{{true}}} and "see through them", otherwise {{{false}}}
	 * to treat semantic predicates as opaque and add {@link #HIT_PRED} to the
	 * result if one is encountered.
	 * @param addEOF Add {@link Token#EOF} to the result if the end of the
	 * outermost context is reached. This parameter has no effect if {{{ctx}}}
	 * is {{{null}}}.
	 */
    protected void _LOOK(ATNState s,
						 ATNState stop_state,
						 PredictionContext ctx,
						 IntervalSet look,
                         Set<ATNConfig> look_busy,
						 BitSet calledRuleStack,
						 bool seeThruPreds, bool addEOF)
	{
//		System.out.println("_LOOK("+s.stateNumber+", ctx="+ctx);
        ATNConfig c = new ATNConfig(s, 0, ctx);
        if ( !look_busy.add(c) ) return;

		if (s == stop_state) {
			if (ctx == null) {
				look.add(Token.EPSILON);
				return;
			}
			else if (ctx.isEmpty() && addEOF) {
				look.add(Token.EOF);
				return;
			}
		}

        if ( s instanceof Rulestop_state ) {
            if ( ctx==null ) {
                look.add(Token.EPSILON);
                return;
            }
            else if (ctx.isEmpty() && addEOF) {
				look.add(Token.EOF);
				return;
			}

			if ( ctx != PredictionContext.EMPTY ) {
				// run thru all possible stack tops in ctx
				bool removed = calledRuleStack.get(s.ruleIndex);
				try {
					calledRuleStack.clear(s.ruleIndex);
					for (int i = 0; i < ctx.size(); i++) {
						ATNState returnState = atn.states.get(ctx.getReturnState(i));
//					    System.out.println("popping back to "+retState);
						_LOOK(returnState, stop_state, ctx.getParent(i), look, look_busy, calledRuleStack, seeThruPreds, addEOF);
					}
				}
				finally {
					if (removed) {
						calledRuleStack.set(s.ruleIndex);
					}
				}
				return;
			}
        }

        int n = s.getNumberOfTransitions();
        for (int i=0; i<n; i++) {
			Transition t = s.transition(i);
			if ( t.getClass() == RuleTransition.class ) {
				if (calledRuleStack.get(((RuleTransition)t).target.ruleIndex)) {
					continue;
				}

				PredictionContext newContext =
					SingletonPredictionContext.create(ctx, ((RuleTransition)t).followState.stateNumber);

				try {
					calledRuleStack.set(((RuleTransition)t).target.ruleIndex);
					_LOOK(t.target, stop_state, newContext, look, look_busy, calledRuleStack, seeThruPreds, addEOF);
				}
				finally {
					calledRuleStack.clear(((RuleTransition)t).target.ruleIndex);
				}
			}
			else if ( t instanceof AbstractPredicateTransition ) {
				if ( seeThruPreds ) {
					_LOOK(t.target, stop_state, ctx, look, look_busy, calledRuleStack, seeThruPreds, addEOF);
				}
				else {
					look.add(HIT_PRED);
				}
			}
			else if ( t.isEpsilon() ) {
				_LOOK(t.target, stop_state, ctx, look, look_busy, calledRuleStack, seeThruPreds, addEOF);
			}
			else if ( t.getClass() == WildcardTransition.class ) {
				look.addAll( IntervalSet.of(Token.MIN_USER_TOKEN_TYPE, atn.maxTokenType) );
			}
			else {
//				System.out.println("adding "+ t);
				IntervalSet set = t.label();
				if (set != null) {
					if (t instanceof NotSetTransition) {
						set = set.complement(IntervalSet.of(Token.MIN_USER_TOKEN_TYPE, atn.maxTokenType));
					}
					look.addAll(set);
				}
			}
		}
	}
}
