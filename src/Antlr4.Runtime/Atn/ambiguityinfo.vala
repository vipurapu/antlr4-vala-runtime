/* ambiguityinfo.vala
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
using Antlr4.Runtime.Misc;

/**
 * This class represents profiling event information for an ambiguity.
 * Ambiguities are decisions where a particular input resulted in an SLL
 * conflict, followed by LL prediction also reaching a conflict state
 * (indicating a true ambiguity in the grammar).
 *
 * This event may be reported during SLL prediction in cases where the
 * conflicting SLL configuration set provides sufficient information to
 * determine that the SLL conflict is truly an ambiguity. For example, if none
 * of the ATN configurations in the conflicting SLL configuration set have
 * traversed a global follow transition (i.e.
 * {@link ATNConfig#reachesIntoOuterContext} is 0 for all configurations), then
 * the result of SLL prediction for that input is known to be equivalent to the
 * result of LL prediction for that input.
 *
 * In some cases, the minimum represented alternative in the conflicting LL
 * configuration set is not equal to the minimum represented alternative in the
 * conflicting SLL configuration set. Grammars and inputs which result in this
 * scenario are unable to use {@link PredictionMode#SLL}, which in turn means
 * they cannot use the two-stage parsing strategy to improve parsing performance
 * for that input.
 *
 * @see ParserATNSimulator#reportAmbiguity
 * @see ANTLRErrorListener#reportAmbiguity
 *
 * @since 4.3
 */
public class Antlr4.Runtime.Atn.AmbiguityInfo : DecisionEventInfo
{
	/** The set of alternative numbers for this decision event that lead to a valid parse. */
	public BitSet ambig_alts;

	/**
	 * Constructs a new instance of the {@link AmbiguityInfo} class with the
	 * specified detailed ambiguity information.
	 *
	 * @param decision The decision number
	 * @param configs The final configuration set identifying the ambiguous
	 * alternatives for the current input
	 * @param ambig_alts The set of alternatives in the decision that lead to a valid parse.
	 *                  The predicted alt is the min(ambig_alts)
	 * @param input The input token stream
	 * @param start_index The start index for the current prediction
	 * @param stop_index The index at which the ambiguity was identified during
	 * prediction
	 * @param full_ctx {{{true}}} if the ambiguity was identified during LL
	 * prediction; otherwise, {{{false}}} if the ambiguity was identified
	 * during SLL prediction
	 */
	public AmbiguityInfo(int decision,
						 ATNConfigSet configs,
						 BitSet ambig_alts,
						 TokenStream input, int start_index, int stop_index,
						 bool full_ctx)
	{
		base(decision, configs, input, start_index, stop_index, full_ctx);
		this.ambig_alts = ambig_alts;
	}
}
