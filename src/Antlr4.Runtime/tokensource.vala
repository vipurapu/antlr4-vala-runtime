/* tokensource.vala
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

/**
 * A source of tokens must provide a sequence of tokens via {@link #next_token()}
 * and also must reveal it's source of characters; {@link CommonToken}'s text is
 * computed from a {@link CharStream}; it only store indices into the char
 * stream.
 *
 * Errors from the lexer are never passed to the parser. Either you want to keep
 * going or you do not upon token recognition error. If you do not want to
 * continue lexing then you do not want to continue parsing. Just throw an
 * exception not under {@link RecognitionException} and Java will naturally toss
 * you all the way out of the recognizers. If you want to continue lexing then
 * you should not throw an exception to the parser--it has already requested a
 * token. Keep lexing until you get a valid one. Just report errors and keep
 * going, looking for a valid token.
 */
public interface Antlr4.Runtime.TokenSource : GLib.Object
{
	/**
	 * Return a {@link Token} object from your input stream (usually a
	 * {@link CharStream}). Do not fail/return upon lexing error; keep chewing
	 * on the characters until you get a good one; errors are not passed through
	 * to the parser.
	 */
	public abstract Token next_token();

	/**
	 * Get the line number for the current position in the input stream. The
	 * first line in the input is line 1.
	 *
	 * @return The line number for the current position in the input stream, or
	 * 0 if the current token source does not track line numbers.
	 */
	public abstract int get_line();

	/**
	 * Get the index into the current line for the current position in the input
	 * stream. The first character on a line has position 0.
	 *
	 * @return The line number for the current position in the input stream, or
	 * -1 if the current token source does not track character positions.
	 */
	public abstract int get_char_position_in_line();

	/**
	 * Get the {@link CharStream} from which this token source is currently
	 * providing tokens.
	 *
	 * @return The {@link CharStream} associated with the current position in
	 * the input, or {{{null}}} if no input stream is available for the token
	 * source.
	 */
	public abstract CharStream get_input_stream();

	/**
	 * Gets the name of the underlying input source. This method returns a
	 * non-null, non-empty string. If such a name is not known, this method
	 * returns {@link IntStream#UNKNOWN_SOURCE_NAME}.
	 */
	public abstract string get_source_name();

	/**
	 * The {@link TokenFactory} this token source should use for creating
	 * {@link Token} objects from the input.
	 */
	public abstract TokenFactory token_factory { get; set; }
}
