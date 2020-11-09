/* atnconfig.vala
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
 * A tuple: (ATN state, predicted alt, syntactic, semantic context).
 * The syntactic context is a graph-structured stack node whose
 * path(s) to the root is the rule invocation(s)
 * chain used to arrive at the state.  The semantic context is
 * the tree of semantic predicates encountered before reaching
 * an ATN state.
 */
public class Antlr4.Runtime.Atn.ATNConfig : GLib.Object, Hashable
{
	/**
	 * This field stores the bit mask for implementing the
	 * {@link #is_precedence_filter_suppressed} property as a bit within the
	 * existing {@link #reaches_into_outer_context} field.
	 */
	private const int SUPPRESS_PRECEDENCE_FILTER = 0x40000000;

	/** The ATN state associated with this configuration */
	public ATNState? state { get; protected set; }

	/** What alt (or lexer rule) is predicted by this configuration */
	public int alt { get; protected set; }

	/** The stack of invoking states leading to the rule/states associated
	 *  with this config.  We track only those contexts pushed during
	 *  execution of the ATN simulator.
	 */
	public PredictionContext? context;

	/**
	 * We cannot execute predicates dependent upon local context unless
	 * we know for sure we are in the correct context. Because there is
	 * no way to do this efficiently, we simply cannot evaluate
	 * dependent predicates unless we are in the rule that initially
	 * invokes the ATN simulator.
	 *
	 * closure() tracks the depth of how far we dip into the outer context:
	 * depth &gt; 0.  Note that it may not be totally accurate depth since I
	 * don't ever decrement. TODO: make it a boolean then
	 *
	 * For memory efficiency, the {@link #is_precedence_filter_suppressed} method
	 * is also backed by this field. Since the field is publicly accessible, the
	 * highest bit which would not cause the value to become negative is used to
	 * store this field. This choice minimizes the risk that code which only
	 * compares this value to 0 would be affected by the new purpose of the
	 * flag. It also ensures the performance of the existing {@link ATNConfig}
	 * constructors as well as certain operations like
	 * {@link ATNConfigSet#add(ATNConfig, DoubleKeyMap)} method are
	 * //completely// unaffected by the change.
	 */
	public int reaches_into_outer_context;


    public SemanticContext semantic_context { get; protected set; }

	public ATNConfig.copy(ATNConfig old) // dup
	{
		this.state = old.state;
		this.alt = old.alt;
		this.context = old.context;
		this.semantic_context = old.semantic_context;
		this.reaches_into_outer_context = old.reaches_into_outer_context;
	}
	public ATNConfig(ATNState state,
					 int alt,
					 PredictionContext context,
					 SemanticContext semantic_context = SemanticContext.NONE)
	{
		this.state = state;
		this.alt = alt;
		this.context = context;
		this.semantic_context = semantic_context;
	}
	public ATNConfig.state(ATNConfig c, ATNState state,
		 SemanticContext semantic_context = c.semantic_context)
    {
		this(c, state, c.context, semantic_context);
	}

	public ATNConfig.context(ATNConfig c,
					 SemanticContext semantic_context)
	{
		this(c, c.state, c.context, semantic_context);
	}

	public ATNConfig.full(ATNConfig c, ATNState state,
					 PredictionContext context,
                     SemanticContext semantic_context = c.semantic_context)
    {
		this.state = state;
		this.alt = c.alt;
		this.context = context;
		this.semantic_context = semantic_context;
		this.reaches_into_outer_context = c.reaches_into_outer_context;
	}

	/**
	 * This property is the value of the {@link #reaches_into_outer_context} field
	 * as it existed prior to the introduction of the
	 * {@link #is_precedence_filter_suppressed} method.
	 */
	public sealed int outer_context_depth
	{
	    get
	    {
		    return reaches_into_outer_context & ~SUPPRESS_PRECEDENCE_FILTER;
		}
	}

	public sealed bool is_precedence_filter_suppressed
	{
	    get
	    {
		    return (reaches_into_outer_context & SUPPRESS_PRECEDENCE_FILTER) != 0;
		}
		set
		{
		    if (value)
			    this.reaches_into_outer_context |= 0x40000000;
		    else this.reaches_into_outer_context &= ~SUPPRESS_PRECEDENCE_FILTER;
		}
	}

	/**
	 * An ATN configuration is equal to another if both have
     * the same state, they predict the same alternative, and
     * syntactic/semantic contexts are the same.
     */
	public bool equals(ATNConfig other)
	{
		if (this == other)
			return true;

		else if (other == null)
			return false;

		return (this.state.state_number == other.state.state_number)
			&& (this.alt == other.alt)
			&& (this.context == other.context || (this.context != null && this.context.equals(other.context)))
			&& (this.semantic_context.equals(other.semantic_context))
			&& (this.is_precedence_filter_suppressed == other.is_precedence_filter_suppressed);
	}

	public override uint64 hash_code()
	{
	    uint64 hash;

		hash = MurmurHash.initialize(7);
		hash = MurmurHash.update(hash, state.stateNumber);
		hash = MurmurHash.update(hash, alt);
		hash = MurmurHash.update(hash, context);
		hash = MurmurHash.update(hash, semantic_context);
		hash = MurmurHash.finish(hash, 4);
		return hash;
	}

	public string to_string(Recognizer? recog = null, bool show_alt = true)
	{
		StringBuilder buf = new StringBuilder();
		buf.append_c('(');
		buf.append(state.to_string());
		if (show_alt)
		{
            buf.append(",");
            buf.append(alt.to_string());
        }
        if (context != null)
        {
            buf.append(",[");
            buf.append(context.to_string());
			buf.append("]");
        }
        if (semantic_context != null && semantic_context != semantic_context.NONE)
        {
            buf.append(",");
            buf.append(semantic_context.to_string());
        }
        if (outer_context_depth > 0)
            buf.append(",up=").append(outer_context_depth.to_string());

		buf.append_c(')');
		return buf.str;
    }
}
