/* vocabulary.vala
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
 * This interface provides information about the vocabulary used by a
 * recognizer.
 *
 * @see Recognizer#getVocabulary()
 * @author Valio Valtokari
 */
public interface Antlr4.Runtime.Vocabulary : GLib.Object
{
	/**
	 * Returns the highest token type value. It can be used to iterate from
	 * zero to that number, inclusively, thus querying all stored entries.
	 * @return the highest token type value
	 */
	public abstract int get_max_token_type();

	/**
	 * Gets the string literal associated with a token type. The string returned
	 * by this method, when not {{{null}}}, can be used unaltered in a parser
	 * grammar to represent this token type.
	 *
	 * The following table shows examples of lexer rules and the literal
	 * names assigned to the corresponding token types.
	 *
	 * || ''Rule''             || ''Literal Name'' || Java String Literal ||
	 * || {{{THIS : 'this';}}} || {{{'this'}}}     || {{{"'this'"}}}      ||
	 * || {{{SQUOTE : '\'';}}} || {{{'\''}}}       || {{{"'\\''"}}}       ||
	 * || {{{ID : [A-Z]+;}}}   || n/a              || {{{null}}}          ||
	 *
	 * @param token_type The token type.
	 *
	 * @return The string literal associated with the specified token type, or
	 * {{{null}}} if no string literal is associated with the type.
	 */
	public abstract string get_literal_name(int token_type);

	/**
	 * Gets the symbolic name associated with a token type. The string returned
	 * by this method, when not {{{null}}}, can be used unaltered in a parser
	 * grammar to represent this token type.
	 *
	 * This method supports token types defined by any of the following
	 * methods:
	 *
	 *  * Tokens created by lexer rules.
	 *  * Tokens defined in a {{{tokens{} }}} block in a lexer or parser
	 *    grammar.
	 *  * The implicitly defined {{{EOF}}} token, which has the token type
	 *    {@link Token#EOF}.
	 *
	 * The following table shows examples of lexer rules and the literal
	 * names assigned to the corresponding token types.
	 *
	 * || ''Rule''             || ''Symbolic Name'' ||
	 * || {{{THIS : 'this';}}} || {{{THIS}}}        ||
	 * || {{{SQUOTE : '\'';}}} || {{{SQUOTE}}}      ||
	 * || {{{ID : [A-Z]+;}}}   || {{{ID}}}}         ||
	 *
	 * @param token_type The token type.
	 *
	 * @return The symbolic name associated with the specified token type, or
	 * {{{null}}} if no symbolic name is associated with the type.
	 */
	public abstract string get_symbolic_name(int token_type);

	/**
	 * Gets the display name of a token type.
	 *
	 * ANTLR provides a default implementation of this method, but
	 * applications are free to override the behavior in any manner which makes
	 * sense for the application. The default implementation returns the first
	 * result from the following list which produces a non-{{{null}}}
	 * result.
	 *
	 *  # The result of {@link #getLiteralName}
	 *  # The result of {@link #getSymbolicName}
	 *  # The result of {@link Integer#toString}
	 *
	 * @param token_type The token type.
	 *
	 * @return The display name of the token type, for use in error reporting or
	 * other user-visible messages which reference specific token types.
	 */
	public abstract string get_display_name(int token_type);
}
