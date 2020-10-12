/* decisioneventinfo.vala
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
 * This is the base class for gathering detailed information about prediction
 * events which occur during parsing.
 *
 * Note that we could record the parser call stack at the time this event
 * occurred but in the presence of left recursive rules, the stack is kind of
 * meaningless. It's better to look at the individual configurations for their
 * individual stacks. Of course that is a {@link PredictionContext} object
 * not a parse tree node and so it does not have information about the extent
 * (start...stop) of the various subtrees. Examining the stack tops of all
 * configurations provide the return states for the rule invocations.
 * From there you can get the enclosing rule.
 *
 * @since 4.3
 */
[Version (since = "4.3")]
public class Antlr4.Runtime.Atn.DecisionEventInfo
{
	/**
	 * The invoked decision number which this event is related to.
	 *
	 * @see ATN#decisionToState
	 */
	public int decision { get; protected set; }

	/**
	 * The configuration set containing additional information relevant to the
	 * prediction state when the current event occurred, or {@code null} if no
	 * additional information is relevant or available.
	 */
	public ATNConfigSet configs { get; protected set; }

	/**
	 * The input token stream which is being parsed.
	 */
	public TokenStream input { get; protected set; }

	/**
	 * The token index in the input stream at which the current prediction was
	 * originally invoked.
	 */
	public int start_index { get; protected set; }

	/**
	 * The token index in the input stream at which the current event occurred.
	 */
	public int stop_index { get; protected set; }

	/**
	 * {@code true} if the current event occurred during LL prediction;
	 * otherwise, {@code false} if the input occurred during SLL prediction.
	 */
	public bool full_ctx { get; protected set; }

	public DecisionEventInfo(int decision,
							 ATNConfigSet configs,
							 TokenStream input, int start_index, int stop_index,
							 bool full_ctx)
	{
		this.decision = decision;
		this.full_ctx = full_ctx;
		this.stop_index = stop_index;
		this.input = input;
		this.start_index = start_index;
		this.configs = configs;
	}
}
