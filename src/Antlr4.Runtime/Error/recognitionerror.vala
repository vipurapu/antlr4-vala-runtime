/* recognitionerror.vala
 *
 * Copyright 2020 Valio Valtokari <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
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
 * The root of the ANTLR exception hierarchy. In general, ANTLR tracks just
 * 3 kinds of errors: prediction errors, failed predicate errors, and
 * mismatched input errors. In each case, the parser knows where it is
 * in the input, where it is in the ATN, the rule invocation stack,
 * and what kind of problem occurred.
 */
public class Antlr4.Runtime.Error.RecognitionError : BaseError
{
	/** The {@link Recognizer} where this exception originated. */
	private Recognizer recognizer { get; private set; }

	private RuleContext ctx { get; private set; }

	private IntStream input { get; private set; }

	/**
	 * The current {@link Token} when an error occurred. Since not all streams
	 * support accessing symbols by index, we have to track the {@link Token}
	 * instance itself.
	 */
	public Token offending_token { get; private set; }

    public int offending_state { get; private set;}

	public RecognitionError(Recognizer? recognizer,
								IntStream input,
								ParserRuleContext ctx)
	{
	    base();
		this.recognizer = recognizer;
		this.input = input;
		this.ctx = ctx;
		if (recognizer != null) this.offending_state = recognizer.state;
	}

	public RecognitionException(String message,
								Recognizer<?, ?> recognizer,
								IntStream input,
								ParserRuleContext ctx)
	{
		super(message);
		this.recognizer = recognizer;
		this.input = input;
		this.ctx = ctx;
		if ( recognizer!=null ) this.offendingState = recognizer.getState();
	}

	/**
	 * Get the ATN state number the parser was in at the time the error
	 * occurred. For {@link NoViableAltException} and
	 * {@link LexerNoViableAltException} exceptions, this is the
	 * {@link DecisionState} number. For others, it is the state whose outgoing
	 * edge we couldn't match.
	 *
	 * <p>If the state number is not known, this method returns -1.</p>
	 */
	public int getOffendingState() {
		return offendingState;
	}

	protected final void setOffendingState(int offendingState) {
		this.offendingState = offendingState;
	}

	/**
	 * Gets the set of input symbols which could potentially follow the
	 * previously matched symbol at the time this exception was thrown.
	 *
	 * <p>If the set of expected tokens is not known and could not be computed,
	 * this method returns {@code null}.</p>
	 *
	 * @return The set of token types that could potentially follow the current
	 * state in the ATN, or {@code null} if the information is not available.
	 */
	public IntervalSet getExpectedTokens() {
		if (recognizer != null) {
			return recognizer.getATN().getExpectedTokens(offendingState, ctx);
		}

		return null;
	}

	/**
	 * Gets the {@link RuleContext} at the time this exception was thrown.
	 *
	 * <p>If the context is not available, this method returns {@code null}.</p>
	 *
	 * @return The {@link RuleContext} at the time this exception was thrown.
	 * If the context is not available, this method returns {@code null}.
	 */
	public RuleContext getCtx() {
		return ctx;
	}

	/**
	 * Gets the input stream which is the symbol source for the recognizer where
	 * this exception was thrown.
	 *
	 * <p>If the input stream is not available, this method returns {@code null}.</p>
	 *
	 * @return The input stream which is the symbol source for the recognizer
	 * where this exception was thrown, or {@code null} if the stream is not
	 * available.
	 */
	public IntStream getInputStream() {
		return input;
	}


	public Token getOffendingToken() {
		return offendingToken;
	}

	protected final void setOffendingToken(Token offendingToken) {
		this.offendingToken = offendingToken;
	}

	/**
	 * Gets the {@link Recognizer} where this exception occurred.
	 *
	 * <p>If the recognizer is not available, this method returns {@code null}.</p>
	 *
	 * @return The recognizer where this exception occurred, or {@code null} if
	 * the recognizer is not available.
	 */
	public Recognizer<?, ?> getRecognizer() {
		return recognizer;
	}
}
