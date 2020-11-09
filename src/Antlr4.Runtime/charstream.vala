/* charstream.vala
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

/** A source of characters for an ANTLR lexer. */
public interface Antlr4.Runtime.CharStream : IntStream
{
	/**
	 * This method returns the text for a range of characters within this input
	 * stream. This method is guaranteed to not throw an exception if the
	 * specified {{{interval}}} lies entirely within a marked range. For more
	 * information about marked ranges, see {@link IntStream#mark}.
	 *
	 * @param interval an interval within the stream
	 *
	 * @return the text of the specified interval
	 *
	 * @throws NullPointerException if {{{interval}}} is {{{null}}}
	 *
	 * @throws IllegalArgumentException if {{{interval.a < 0}}}, or if
	 * {{{interval.b < interval.a - 1}}}, or if {{{interval.b}}} lies at or
	 * past the end of the stream
	 *
	 * @throws UnsupportedOperationException if the stream does not support
	 * getting the text of the specified interval
	 */
	public abstract string get_text(Interval interval);
}
