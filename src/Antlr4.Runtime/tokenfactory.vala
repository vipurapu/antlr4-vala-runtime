/* tokenfactory.vala
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
 * The default mechanism for creating tokens. It's used by default in Lexer and
 * the error handling strategy (to create missing tokens).  Notifying the parser
 * of a new factory means that it notifies its token source and error strategy.
 */
public interface Antlr4.Runtime.TokenFactory<S>
{
	/**
	 * This is the method used to create tokens in the lexer and in the
	 * error handling strategy. If text != null, than the start and stop positions
	 * are wiped to -1 in the text override is set in the CommonToken.
	 */
	public abstract S create(Pair<TokenSource, CharStream> source, int type, string text,
				  int channel, int start, int stop,
				  int line, int char_position_in_line) ensures (result is GLib.Object);

	/** Generically useful */
	public abstract S _create(int type, string text) ensures (result is GLib.Object);
}
