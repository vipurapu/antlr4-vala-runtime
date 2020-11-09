/* parsetree.vala
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
 * An interface to access the tree of {@link RuleContext} objects created
 * during a parse that makes the data structure look like a simple parse tree.
 * This node represents both internal nodes, rule invocations,
 * and leaf nodes, token matches.
 *
 * The payload is either a {@link Token} or a {@link RuleContext} object.
 */
public interface Antlr4.Runtime.Tree.ParseTree : SyntaxTree
{
	/** The {@link ParseTreeVisitor} needs a double dispatch method. */
	T accept<T>(ParseTreeVisitor<T> visitor);

	/**
	 * Return the combined text of all leaf nodes. Does not get any
	 * off-channel tokens (if any) so won't return whitespace and
	 * comments if they are sent to parser on hidden channel.
	 */
	public abstract string get_text();

	/**
	 * Specialize toStringTree so that it can print out more information
	 * based upon the parser.
	 */
	public abstract string to_string_tree(Parser? parser);
}
