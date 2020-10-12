/* token.vala
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
 * WITHOUT WARRANTIEsS OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
using Antlr4.Runtime;

/**
 * A token has properties: text, type, line, character position in the line
 * (so we can ignore tabs), token channel, index, and source from which
 * we obtained this token.
 */
public interface Antlr4.Runtime.Token : GLib.Object
{
	public const int INVALID_TYPE = 0;

    /**
     * During lookahead operations, this "token" signifies we hit rule end ATN state
     * and did not follow it despite needing to.
     */
    public const int EPSILON = -2;

	public const int MIN_USER_TOKEN_TYPE = 1;

    public const int EOF = IntStream.EOF;

	/**
	 * All tokens go to the parser (unless skip() is called in that rule)
	 * on a particular "channel".  The parser tunes to a particular channel
	 * so that whitespace etc... can go to the parser on a "hidden" channel.
	 */
	public const int DEFAULT_CHANNEL = 0;

	/**
	 * Anything on different channel than DEFAULT_CHANNEL is not parsed
	 * by parser.
	 */
	public const int HIDDEN_CHANNEL = 1;

	/**
	 * This is the minimum constant value which can be assigned to a
	 * user-defined token channel.
	 *
	 * <p>
	 * The non-negative numbers less than {@link #MIN_USER_CHANNEL_VALUE} are
	 * assigned to the predefined channels {@link #DEFAULT_CHANNEL} and
	 * {@link #HIDDEN_CHANNEL}.</p>
	 *
	 * @see Token#getChannel()
	 */
	public const int MIN_USER_CHANNEL_VALUE = 2;

	/**
	 * Get the text of the token.
	 */
	public abstract string? text { get; protected set; }

	/** Get the token type of the token */
	public abstract int type { get; protected set; }

	/**
	 * The line number on which the 1st character of this token was matched,
	 * line=1..n
	 */
	public abstract int line { get; protected set; }

	/**
	 * The index of the first character of this token relative to the
	 * beginning of the line at which it occurs, 0..n-1
	 */
	public abstract int char_position_in_line { get; protected set; }

	/**
	 * Return the channel this token. Each token can arrive at the parser
	 * on a different channel, but the parser only "tunes" to a single channel.
	 * The parser ignores everything not on DEFAULT_CHANNEL.
	 */
	public abstract int channel { get; protected set; }

	/**
	 * An index from 0..n-1 of the token object in the input stream.
	 * This must be valid in order to print token streams and
	 * use TokenRewriteStream.
	 *
	 * Return -1 to indicate that this token was conjured up since
	 * it doesn't have a valid index.
	 */
	public abstract int token_index { get; protected set; }

	/**
	 * The starting character index of the token
	 * This method is optional; return -1 if not implemented.
	 */
	public abstract int start_index { get; protected set; }

	/**
	 * The last character index of the token.
	 * This method is optional; return -1 if not implemented.
	 */
	public abstract int stop_index { get; protected set; }

	/**
	 * Gets the {@link TokenSource} which created this token.
	 */
	public abstract TokenSource token_source { get; protected set; }

	/**
	 * Gets the {@link CharStream} from which this token was derived.
	 */
	public abstract CharStream input_stream { get; protected set; }
}
