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
	 * by this method, when not {@code null}, can be used unaltered in a parser
	 * grammar to represent this token type.
	 *
	 * <p>The following table shows examples of lexer rules and the literal
	 * names assigned to the corresponding token types.</p>
	 *
	 * <table>
	 *  <tr>
	 *   <th>Rule</th>
	 *   <th>Literal Name</th>
	 *   <th>Java String Literal</th>
	 *  </tr>
	 *  <tr>
	 *   <td>{@code THIS : 'this';}</td>
	 *   <td>{@code 'this'}</td>
	 *   <td>{@code "'this'"}</td>
	 *  </tr>
	 *  <tr>
	 *   <td>{@code SQUOTE : '\'';}</td>
	 *   <td>{@code '\''}</td>
	 *   <td>{@code "'\\''"}</td>
	 *  </tr>
	 *  <tr>
	 *   <td>{@code ID : [A-Z]+;}</td>
	 *   <td>n/a</td>
	 *   <td>{@code null}</td>
	 *  </tr>
	 * </table>
	 *
	 * @param token_type The token type.
	 *
	 * @return The string literal associated with the specified token type, or
	 * {@code null} if no string literal is associated with the type.
	 */
	public abstract string get_literal_name(int token_type);

	/**
	 * Gets the symbolic name associated with a token type. The string returned
	 * by this method, when not {@code null}, can be used unaltered in a parser
	 * grammar to represent this token type.
	 *
	 * <p>This method supports token types defined by any of the following
	 * methods:</p>
	 *
	 * <ul>
	 *  <li>Tokens created by lexer rules.</li>
	 *  <li>Tokens defined in a <code>tokens{}</code> block in a lexer or parser
	 *  grammar.</li>
	 *  <li>The implicitly defined {@code EOF} token, which has the token type
	 *  {@link Token#EOF}.</li>
	 * </ul>
	 *
	 * <p>The following table shows examples of lexer rules and the literal
	 * names assigned to the corresponding token types.</p>
	 *
	 * <table>
	 *  <tr>
	 *   <th>Rule</th>
	 *   <th>Symbolic Name</th>
	 *  </tr>
	 *  <tr>
	 *   <td>{@code THIS : 'this';}</td>
	 *   <td>{@code THIS}</td>
	 *  </tr>
	 *  <tr>
	 *   <td>{@code SQUOTE : '\'';}</td>
	 *   <td>{@code SQUOTE}</td>
	 *  </tr>
	 *  <tr>
	 *   <td>{@code ID : [A-Z]+;}</td>
	 *   <td>{@code ID}</td>
	 *  </tr>
	 * </table>
	 *
	 * @param token_type The token type.
	 *
	 * @return The symbolic name associated with the specified token type, or
	 * {@code null} if no symbolic name is associated with the type.
	 */
	public abstract string get_symbolic_name(int token_type);

	/**
	 * Gets the display name of a token type.
	 *
	 * <p>ANTLR provides a default implementation of this method, but
	 * applications are free to override the behavior in any manner which makes
	 * sense for the application. The default implementation returns the first
	 * result from the following list which produces a non-{@code null}
	 * result.</p>
	 *
	 * <ol>
	 *  <li>The result of {@link #getLiteralName}</li>
	 *  <li>The result of {@link #getSymbolicName}</li>
	 *  <li>The result of {@link Integer#toString}</li>
	 * </ol>
	 *
	 * @param token_type The token type.
	 *
	 * @return The display name of the token type, for use in error reporting or
	 * other user-visible messages which reference specific token types.
	 */
	public abstract string get_display_name(int token_type);
}
