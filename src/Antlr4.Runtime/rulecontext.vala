/* rulecontext.vala
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
 * A rule context is a record of a single rule invocation.
 *
 * We form a stack of these context objects using the parent
 * pointer. A parent pointer of null indicates that the current
 * context is the bottom of the stack. The ParserRuleContext subclass
 * as a children list so that we can turn this data structure into a
 * tree.
 *
 * The root node always has a null pointer and invoking_state of -1.
 *
 * Upon entry to parsing, the first invoked rule function creates a
 * context object (a subclass specialized for that rule such as
 * SContext) and makes it the root of a parse tree, recorded by field
 * Parser._ctx.
 * {{{
 * public final SContext s() throws RecognitionException {
 *     SContext _localctx = new SContext(_ctx, getState()); <-- create new node
 *     enterRule(_localctx, 0, RULE_s);                     <-- push it
 *     ...
 *     exitRule();                                          <-- pop back to _localctx
 *     return _localctx;
 * }
 * }}}
 * A subsequent rule invocation of r from the start rule s pushes a
 * new context object for r whose parent points at s and use invoking
 * state is the state with r emanating as edge label.
 *
 * The invoking_state fields from a context object to the root
 * together form a stack of rule indication states where the root
 * (bottom of the stack) has a -1 sentinel value. If we invoke start
 * symbol s then call r1, which calls r2, the  would look like
 * this:
 *
 *    SContext[-1]   <- root node (bottom of the stack)
 *    R1Context[p]   <- p in rule s called r1
 *    R2Context[q]   <- q in rule r1 called r2
 *
 * So the top of the stack, _ctx, represents a call to the current
 * rule and it holds the return address from another rule that invoke
 * to this rule. To invoke a rule, we must always have a current context.
 *
 * The parent contexts are useful for computing lookahead sets and
 * getting error information.
 *
 * These objects are used during parsing and prediction.
 * For the special case of parsers, we use the subclass
 * ParserRuleContext.
 *
 * @see ParserRuleContext
 */
using Antlr4.Runtime.Tree;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Atn;

public class Antlr4.Runtime.RuleContext : GLib.Object, RuleNode, ParseTree, SyntaxTree, BaseTree
{
	public static ParserRuleContext EMPTY { get; default = new ParserRuleContext(); }

	/**
	 * What state invoked the rule associated with this context?
	 * The "return address" is the follow_state of invoking_state
	 * If parent is null, this should be -1 this context object represents
	 * the start rule.
	 */
	public int invoking_state = -1;

	public RuleContext.empty() {  }

	public RuleContext(RuleContext parent, int invoking_state)
	{
		this.parent = parent;
		this.invoking_state = invoking_state;
	}

	public int depth
	{
	    get
	    {
		    int n = 0;
		    RuleContext p = this;
		    while (p != null)
		    {
			    p = p.parent;
		    	n++;
		    }
		    return n;
		}
	}

	/**
	 * A context is empty if there is no invoking state; meaning nobody called
	 * current context.
	 */
	public bool is_empty
	{
	    get
	    {
		    return invoking_state == -1;
		}
	}

	// satisfy the ParseTree / SyntaxTree interface

	public override Interval source_interval
	{
	    get
	    {
		    return Interval.INVALID;
        }
	}

	public override RuleContext rule_context
	{
	    get
	    {
	        return this;
	    }
	}

	public override BaseTree parent
	{
	    get
	    {
	        return parent;
	    }

	    set
	    {
	        this.parent = value;
	    }
	}

	public override Object payload
	{
	    get
	    {
	        return this;
	    }
	}

	/**
	 * Return the combined text of all child nodes. This method only considers
	 * tokens which have been added to the parse tree.
	 * <p>
	 * Since tokens on hidden channels (e.g. whitespace or comments) are not
	 * added to the parse trees, they will not appear in the output of this
	 * method.
	 */
	public override string get_text()
	{
		if (child_count == 0)
			return "";

		StringBuilder builder = new StringBuilder();
		for (uint i = 0; i < child_count; i++)
			builder.append(child_at(i).get_text());

		return builder.str;
	}

	public BaseTree? child_at(uint i)
	{
		return null;
	}

	public uint child_count
	{
	    get
	    {
	        return 0;
	    }
	}

	public override int rule_index
	{
	    get
	    {
	        return -1;
	    }
	}

	/**
	 * For rule associated with this parse tree internal node, return
	 * the outer alternative number used to match the input. Default
	 * implementation does not compute nor store this alt num. Create
	 * a subclass of ParserRuleContext with backing field and set
	 * option contextSuperClass.
	 * to set it.
	 *
	 * @since 4.5.3
	 */
	[Version (since = "4.5.3")]
	public int get_alt_number()
	{
	    return ATN.INVALID_ALT_NUMBER;
	}

	/**
	 * Set the outer alternative number for this context node. Default
	 * implementation does nothing to avoid backing field overhead for
	 * trees that don't need it.  Create
     * a subclass of ParserRuleContext with backing field and set
     * option contextSuperClass.
	 *
	 * @since 4.5.3
	 */
	[Version (since = "4.5.3")]
	public void set_alt_number(int alt_number) {  }

	public T accept<T>(ParseTreeVisitor<T> visitor)
	{
	    return visitor.visit_children(this);
	}

	/**
	 * Print out a whole tree, not just a node, in LISP format
	 * (root child1 .. childN). Print just a node if this is a leaf.
	 * We have to know the recognizer so we can get rule names.
	 */
	public string to_string_tree(Parser recog)
	{
		return Trees.to_string_tree(this, recog);
	}

	/** Print out a whole tree, not just a node, in LISP format
	 * (root child1 .. childN). Print just a node if this is a leaf.
	 */
	public string to_string_tree_from_rule_names(Gee.List<string>? rule_names)
	{
		return Trees.to_string_tree_from_rule_names(this, rule_names);
	}


	public string to_basic_string_tree()
	{
		return to_string_tree_from_rule_names(null);
	}

	public string to_string(Gee.List<string> rule_names, RuleContext stop)
	{
		StringBuilder buf = new StringBuilder();
		RuleContext p = this;
		buf.append("[");
		while (p != null && p != stop)
		{
			if (rule_names == null)
			{
				if (!p.is_empty)
					buf.append(p.invoking_state.to_string());
			}
			else
			{
				int rule_index = p.rule_index;
				string rule_name = rule_index >= 0 && rule_index < rule_names.size() ? rule_names[rule_index] : Integer.toString(rule_index);
				buf.append(rule_name);
			}

			if (p.parent != null && (rule_names != null || !p.parent.is_empty))
				buf.append(" ");

			p = p.parent;
		}

		buf.append("]");
		return buf.str;
	}
}
