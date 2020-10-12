/* baseerrorlistener.vala
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
using Antlr4.Runtime.Error;
using Antlr4.Runtime.Misc;

/**
 * Provides an empty default implementation of {@link ANTLRErrorListener}. The
 * default implementation of each method does nothing, but can be overridden as
 * necessary.
 *
 * @author Valio Valtokari
 */
public class Antlr4.Runtime.BaseErrorListener : GLib.Object, ANTLRErrorListener
{
	public virtual void syntax_error(Recognizer recognizer,
							         Object offendingSymbol,
							         int line,
							         int char_position_in_line,
							         string msg,
							         RecognitionError e)
	{
	}

	public virtual void report_ambiguity(Parser recognizer,
								         DFA dfa,
								         int start_index,
								         int stop_index,
								         bool exact,
								         BitSet ambig_alts,
								         ATNConfigSet configs)
	{
	}

	public virtual void report_attempting_full_context(Parser recognizer,
											           DFA dfa,
											           int start_index,
											           int stop_index,
											           BitSet conflicting_alts,
											           ATNConfigSet configs)
	{
	}

	public virtual void report_context_sensitivity(Parser recognizer,
										           DFA dfa,
										           int start_index,
										           int stop_index,
										           int prediction,
										           ATNConfigSet configs)
	{
	}
}
