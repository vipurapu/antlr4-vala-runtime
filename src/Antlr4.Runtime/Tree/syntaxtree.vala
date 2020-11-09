/* syntaxtree.vala
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
 * A tree that knows about an interval in a token stream
 * is some kind of syntax tree. Subinterfaces distinguish
 * between parse trees and other kinds of syntax trees we might want to create.
 */
public interface Antlr4.Runtime.Tree.SyntaxTree : BaseTree
{
	/**
	 * Return an {@link Interval} indicating the index in the
	 * {@link TokenStream} of the first and last token associated with this
	 * subtree. If this node is a leaf, then the interval represents a single
	 * token and has interval i..i for token index i.
	 *
	 * An interval of i..i-1 indicates an empty interval at position
	 * i in the input stream, where 0 <= i <= the size of the input
	 * token stream.  Currently, the code base can only have i=0..n-1 but
	 * in concept one could have an empty interval after EOF.
	 *
	 * If source interval is unknown, this returns {@link Interval#INVALID}.
	 *
	 * As a weird special case, the source interval for rules matched after
	 * EOF is unspecified.
	 */
	public abstract Interval source_interval { get; }
}
